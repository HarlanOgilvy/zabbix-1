# LIBNETSNMP_CHECK_CONFIG ([DEFAULT-ACTION])
# ----------------------------------------------------------
#    Eugene Grigorjev <eugene@zabbix.com>   Feb-02-2007
#
# Checks for net-snmp.  DEFAULT-ACTION is the string yes or no to
# specify whether to default to --with-net-snmp or --without-net-snmp.
# If not supplied, DEFAULT-ACTION is no.
#
# This macro #defines HAVE_SNMP and HAVE_NETSNMP if a required header files is
# found, and sets @SNMP_LDFLAGS@ and @SNMP_CFLAGS@ to the necessary
# values.
#
# Users may override the detected values by doing something like:
# SNMP_LDFLAGS="-lsnmp" SNMP_CFLAGS="-I/usr/myinclude" ./configure
#
# This macro is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

AC_DEFUN([LIBNETSNMP_CHECK_CONFIG],
[
  AC_ARG_WITH(net-snmp,
[
What SNMP package do you want to use (please select only one):
AC_HELP_STRING([--with-net-snmp@<:@=ARG@:>@],
		[use NET-SNMP package @<:@default=no@:>@, default is to search through a number of common places for the NET-SNMP files.])],[ if test "$withval" = "no"; then
            want_netsnmp="no"
            _libnetsnmp_with="no"
        elif test "$withval" = "yes"; then
            want_netsnmp="yes"
            _libnetsnmp_with="yes"
        else
            want_netsnmp="yes"
            _libnetsnmp_with=$withval
        fi
     ],[_libnetsnmp_with=ifelse([$1],,[no],[$1])])

  SNMP_CFLAGS=""
  SNMP_LDFLAGS=""
  SNMP_LIBS=""

  if test "x$_libnetsnmp_with" != x"no"; then

        if test -d "$_libnetsnmp_with" ; then
           SNMP_INCDIR="-I$withval/include"
           _libnetsnmp_ldflags="-L$_libnetsnmp_with/lib"
           AC_PATH_PROG([_libnetsnmp_config],["$_libnetsnmp_with/bin/net-snmp-config"])
        else
   	   AC_PATH_PROG([_libnetsnmp_config],[net-snmp-config])
        fi

	if test "x$_libnetsnmp_config" != "x" ; then

dnl		AC_MSG_CHECKING([for NET-SNMP libraries])

		_full_libnetsnmp_cflags="`$_libnetsnmp_config --cflags`"
		for i in $_full_libnetsnmp_cflags; do
			case $i in
				-I*)
					SNMP_CFLAGS="$SNMP_CFLAGS $i"

			;;
			esac
		done

		_full_libnetsnmp_libs="`$_libnetsnmp_config --libs` -lcrypto"
		for i in $_full_libnetsnmp_libs; do
			case $i in
				-L*)
					SNMP_LDFLAGS="${SNMP_LDFLAGS} ${_libnetsnmp_libdir}"
			;;
			esac
		done

		if test "x$enable_static" = "xyes"; then
			for i in $_full_libnetsnmp_libs; do
				case $i in
					-lnetsnmp)
				;;
					-l*)
						_lib_name="`echo "$i" | cut -b3-`"
						SNMP_LIBS="$SNMP_LIBS $i"

				;;
				esac
			done
		fi

		_save_netsnmp_libs="${LIBS}"
		_save_netsnmp_ldflags="${LDFLAGS}"
		_save_netsnmp_cflags="${CFLAGS}"
		LIBS="${LIBS} ${SNMP_LIBS}"
		LDFLAGS="${LDFLAGS} ${SNMP_LDFLAGS}"
		CFLAGS="${CFLAGS} ${SNMP_CFLAGS}"

		AC_CHECK_LIB(netsnmp , main, , AC_MSG_ERROR([Not found NET-SNMP library]))

		LIBS="${_save_netsnmp_libs}"
		LDFLAGS="${_save_netsnmp_ldflags}"
		CFLAGS="${_save_netsnmp_cflags}"
		unset _save_netsnmp_libs
		unset _save_netsnmp_ldflags
		unset _save_netsnmp_cflags

		SNMP_LIBS="-lnetsnmp ${SNMP_LIBS}"

		AC_DEFINE(HAVE_NETSNMP,1,[Define to 1 if NET-SNMP should be enabled.])
		AC_DEFINE(HAVE_SNMP,1,[Define to 1 if SNMP should be enabled.])

		found_netsnmp="yes"
dnl		AC_MSG_RESULT([yes])
	else
		found_netsnmp="no"
dnl		AC_MSG_RESULT([no])
	fi
  fi

  AC_SUBST(SNMP_CFLAGS)
  AC_SUBST(SNMP_LDFLAGS)
  AC_SUBST(SNMP_LIBS)

  unset _libnetsnmp_with
])dnl
