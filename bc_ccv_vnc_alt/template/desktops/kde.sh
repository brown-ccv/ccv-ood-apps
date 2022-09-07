#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
XDG_SESSION_TYPE=x11;  export XDG_SESSION_TYPE

OS=`uname -s`

# Emulate GDM
USESTARTUP=0
if [ -x /usr/bin/gnome-session ]; then
  # Use Unity 2D on Ubuntu 12 if no WM is specified.  Unity 3D 5.20.x doesn't
  # even pretend to work properly with our X server.
  if [ -f /usr/share/gnome-session/sessions/ubuntu-2d.session -a -z "$TVNC_WM" ]; then
    TVNC_WM=2d
  fi
  case "$TVNC_WM" in
    2d)
      # Ubuntu 12: ubuntu-2d
      # Ubuntu 14: gnome-fallback
      for SESSION in "gnome-fallback" "ubuntu-2d" "2d-gnome"; do
        if [ -f /usr/share/gnome-session/sessions/$SESSION.session ]; then
          DESKTOP_SESSION=$SESSION;  export DESKTOP_SESSION
          XDG_CURRENT_DESKTOP=$SESSION;  export XDG_CURRENT_DESKTOP
        fi
      done
      # RHEL 7, Fedora
      if [ -f /usr/share/gnome-session/sessions/gnome-classic.session ]; then
        DESKTOP_SESSION=gnome-classic;  export DESKTOP_SESSION
        GNOME_SHELL_SESSION_MODE=classic;  export GNOME_SHELL_SESSION_MODE
        XDG_CURRENT_DESKTOP="GNOME-Classic:GNOME";  export XDG_CURRENT_DESKTOP
        USESTARTUP=1
      fi
      # Ubuntu 16+
      if [ -f /usr/share/gnome-session/sessions/gnome-flashback-metacity.session ]; then
        DESKTOP_SESSION=gnome-flashback-metacity;  export DESKTOP_SESSION
        grep -q "unity" /usr/share/gnome-session/sessions/gnome-flashback-metacity.session && {
          XDG_CURRENT_DESKTOP="GNOME-Flashback:Unity"
          export XDG_CURRENT_DESKTOP
        } || {
          XDG_CURRENT_DESKTOP="GNOME-Flashback:GNOME"
          export XDG_CURRENT_DESKTOP
          GNOME_SHELL_SESSION_MODE=ubuntu;  export GNOME_SHELL_SESSION_MODE
          USESTARTUP=1
        }
      fi
      unset TVNC_WM
      ;;
    *)
      # This is necessary to make Unity work on Ubuntu 16, and on Ubuntu 14, it
      # ensures that the proper compiz profile is set up.  Otherwise, if you
      # accidentally launch Unity in a TurboVNC session that lacks OpenGL
      # support, compiz will automatically disable its OpenGL plugin, requiring
      # you to reset the compiz plugin state before Unity will work again.
      if [ -f /usr/share/gnome-session/sessions/ubuntu.session -a "$TVNC_WM" = "" ]; then
        DESKTOP_SESSION=ubuntu;  export DESKTOP_SESSION
        grep -qE "DesktopName\s*=\s*Unity" /usr/share/gnome-session/sessions/ubuntu.session && {
          XDG_CURRENT_DESKTOP=Unity;  export XDG_CURRENT_DESKTOP
        } || {
          XDG_CURRENT_DESKTOP=ubuntu:GNOME;  export XDG_CURRENT_DESKTOP
          GNOME_SHELL_SESSION_MODE=ubuntu;  export GNOME_SHELL_SESSION_MODE
          USESTARTUP=1
        }
      fi
      ;;
  esac
  if [ "$DESKTOP_SESSION" != "" ]; then
    GDMSESSION=$DESKTOP_SESSION;  export GDMSESSION
    SESSIONTYPE=gnome-session;  export SESSIONTYPE
    STARTUP="/usr/bin/gnome-session --session=$DESKTOP_SESSION"
    export STARTUP
  fi
fi

if [ "$TVNC_VGL" = "1" ]; then
  if [ -z "$SSH_AGENT_PID" -a -x /usr/bin/ssh-agent ]; then
    TVNC_SSHAGENT=/usr/bin/ssh-agent
  fi
  if [ -z "$TVNC_VGLRUN" ]; then
    TVNC_VGLRUN="vglrun +wm"
  fi
fi

if [ "$STARTUP" != "" -a "$USESTARTUP" = "1" ]; then
  exec $TVNC_VGLRUN $STARTUP
fi
if [ "$TVNC_WM" = "" ]; then
  # Typical system-wide WM startup script on Linux and Solaris 11
  if [ -f /etc/X11/xinit/xinitrc ]; then
    TVNC_WM=/etc/X11/xinit/xinitrc
  fi
  # Typical system-wide WM startup script on Solaris 10
  if [ $OS = 'SunOS' -a -f /usr/dt/config/Xinitrc.jds ]; then
    TVNC_WM=/usr/dt/config/Xinitrc.jds
  fi
  # Typical per-user WM startup script on Solaris 10
  if [ $OS = 'SunOS' -a -f $HOME/.dt/sessions/lastsession ]; then
    TVNC_WM=`cat $HOME/.dt/sessions/lastsession`
  fi
else
  TVNC_WM=`which "$TVNC_WM" 2>/dev/null`
fi
if [ "$TVNC_WM" != "" ]; then
  if [ -x "$TVNC_WM" ]; then
    exec $TVNC_SSHAGENT $TVNC_VGLRUN "$TVNC_WM"
  else
    exec $TVNC_SSHAGENT $TVNC_VGLRUN sh "$TVNC_WM"
  fi
else
  echo "No window manager startup script found.  Use the TVNC_WM environment"
  echo "variable to specify the path to a window manager startup script or"
  echo "executable.  Falling back to TWM."
  which twm >/dev/null && {
    if [ -f $HOME/.Xresources ]; then xrdb $HOME/.Xresources; fi
    xsetroot -solid grey
    xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
    twm
  } || {
    echo "TWM not found.  I give up."
    exit 1
  }
fi
