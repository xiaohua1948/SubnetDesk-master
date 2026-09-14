# Linux host readiness

SubnetDesk shows host-readiness warnings when the current Linux environment may
prevent reliable incoming remote-control sessions. These warnings do not affect
outgoing connections.

## SELinux

When SELinux is enforcing, its policy may block screen capture, input injection,
or background-service access even if SubnetDesk itself is running.

1. Check the recent denial records with `sudo ausearch -m AVC -ts recent`.
2. Confirm that the denial was produced while reproducing the SubnetDesk issue.
3. Add the narrowest local policy required for that operation. Do not disable
   SELinux globally as a first troubleshooting step.

You can dismiss this warning after the host policy has been configured.

## Wayland session

Wayland support remains limited for unattended control. Screen capture and input
injection depend on the compositor and may require an interactive permission
prompt after every login.

For a Linux machine that must remain remotely accessible without a local user,
select an X11 session from the display manager and then sign in again. You can
continue using Wayland when interactive approval and the compositor's supported
feature set are acceptable.

## Wayland login screen

A Wayland login screen cannot be controlled before the desktop session starts.
This also prevents reconnecting to the login screen after logout.

Configure the display manager to use X11 for its greeter. The exact setting is
distribution-specific; consult the display manager documentation before editing
system configuration, then restart the display manager or reboot the host.

SubnetDesk reports the login-screen warning separately from the current desktop
session because the greeter and the signed-in desktop can use different display
servers.
