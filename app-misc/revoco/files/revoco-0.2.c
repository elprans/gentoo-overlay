/*
 * Simple hack to control the wheel of Logitech's MX-Revolution mouse.
 *
 * Requires hiddev.
 *
 * Written November 2006 by E. Toernig's bonobo - no copyrights.
 * Cleanup by Petteri Räty <betelgeuse@gentoo.org>
 *
 * Contact: Edgar Toernig <froese@gmx.de>
 *
 */

// Needed for hiddev.h
#include <stdlib.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <asm/types.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/hiddev.h>

#include <stdarg.h>
#include <errno.h>

#define streq(a,b)	(strcmp((a), (b)) == 0)
#define strneq(a,b,c)	(strncmp((a), (b), (c)) == 0)

#define LOGITECH	0x046d
#define MX_REVOLUTION	0xc51a

static void
fatal(const char *fmt, ...)
{
    va_list args;

    va_start(args, fmt);
    fprintf(stderr, "revoco: ");
    vfprintf(stderr, fmt, args);
    fprintf(stderr, "\n");
    va_end(args);
    exit(1);
}

static int
open_dev(void)
{
    char buf[128];
    int i, fd;
    struct hiddev_devinfo dinfo;

    for (i = 0; i < 16; ++i)
    {
	sprintf(buf, "/dev/usb/hiddev%d", i);
	fd = open(buf, O_RDWR);
	if (fd >= 0)
	{
	    if (ioctl(fd, HIDIOCGDEVINFO, &dinfo) == 0)
		if (dinfo.vendor == (short)LOGITECH)
		    if (dinfo.product == (short)MX_REVOLUTION)
			return fd;
	    close(fd);
	}
    }
    return -1;
}

static void
close_dev(int fd)
{
    close(fd);
}

static void
send_cmd(int fd, int b1, int b2, int b3)
{
    struct hiddev_usage_ref_multi uref;
    struct hiddev_report_info rinfo;

    uref.uref.report_type = HID_REPORT_TYPE_OUTPUT;
    uref.uref.report_id = 0x10;
    uref.uref.field_index = 0;
    uref.uref.usage_index = 0;
    uref.num_values = 6;
    uref.values[0] = 0x01;	// ET: No idea what the first three values
    uref.values[1] = 0x80;	// mean.  The SetPoint software sends them ...
    uref.values[2] = 0x56;
    uref.values[3] = b1;
    uref.values[4] = b2;
    uref.values[5] = b3;
    if (ioctl(fd, HIDIOCSUSAGES, &uref) == -1)
	fatal("HIDIOCSUSAGES: %s", strerror(errno));

    rinfo.report_type = HID_REPORT_TYPE_OUTPUT;
    rinfo.report_id = 0x10;
    rinfo.num_fields = 1;
    if (ioctl(fd, HIDIOCSREPORT, &rinfo) == -1)
	fatal("HIDIOCSREPORT: %s", strerror(errno));
}


static int
getarg(const char *str, int def, int min, int max)
{
    if (*str == '\0')
	return def;

    if (*str == '=')
    {
	int n = atoi(str + 1);

	if (n >= min && n <= max)
	    return n;

	fatal("argument `%s' out of range (%d-%d)", str + 1, min, max);
    }

    fatal("bad argument `%s'", str);
    return 0;
}

static void
configure(int handle, int argc, char **argv)
{
    int i, arg;

    for (i = 1; i < argc; ++i)
	if (streq(argv[i], "free"))
	{
	    send_cmd(handle, 1, 0, 0);
	}
	else if (streq(argv[i], "click"))
	{
	    send_cmd(handle, 2, 0, 0);
	}
	else if (strneq(argv[i], "manual", 6))
	{
	    arg = getarg(argv[i] + 6, 3, 0, 15);
	    send_cmd(handle, 8, arg, 0);
	    // 3=middle, 4=back, 5=forw, 6=find, 7=wheel-left, 8=wheel-right
	    // 9=sidewheel-forw, 11=sidewheel-back, 13=sidewheel-press
	    // 0+1+2+10+12+14+15=ignore
	}
	else if (strneq(argv[i], "auto", 4))
	{
	    arg = getarg(argv[i] + 4, 5, 1, 47);
	    send_cmd(handle, 5, arg, arg);  // up, down
	}
	else
	    fatal("unknown option `%s'", argv[i]);
}

int
main(int argc, char **argv)
{
    int handle;

    if (argc < 2 ||
	(argc > 1 && (streq(argv[1], "-h") || streq(argv[1], "--help"))))
    {
	printf("Revoco v0.1 - Change the wheel behaviour of "
					"Logitech's MX-Revolution mouse.\n");
	printf("Usage:\n");
	printf("  revoco free            free spinning mode\n");
	printf("  revoco click           click-to-click mode\n");
	printf("  revoco manual[=button] manual mode change via button\n");
	printf("  revoco auto[=speed]    automatic mode change (0<speed<48)\n");
	exit(0);
    }

    handle = open_dev();
    if (handle == -1)
	fatal("No Logitech MX-Revolution (%04x:%04x) found.",
						    LOGITECH, MX_REVOLUTION);
    configure(handle, argc, argv);

    close_dev(handle);
    exit(0);
}
