# hyprlock-v0.9.6-trzn.patch

Patches applied to the hyprlock build installed at `/usr/local/bin/hyprlock`
(it shadows the stock `/usr/bin/hyprlock` in PATH):

1. **Touch focus** (`src/core/Seat.cpp`): set the focused output on touch-down.
   Upstream only does it on pointer enter (and never with `hide_cursor = true`),
   so taps on the lock screen were dropped on a touch-only tablet session.
2. **PIN auto-submit** (`src/core/hyprlock.cpp`): when the input is all digits
   and reaches the length in `/etc/hyprlock-pin.len`, submit without Enter.
   Max 3 auto-tries per lock, never resubmits identical input.
3. **Clean exit** (`src/main.cpp`): destroy `g_pAuth` before `g_dbus`. Static
   destruction order let sdbus proxies outlive their connection → segfault
   inside libsdbus-c++ after every unlock.

Rebuild:

```sh
git clone --depth 1 --branch v0.9.6 https://github.com/hyprwm/hyprlock
cd hyprlock && git apply ~/.config/hypr/patches/hyprlock-v0.9.6-trzn.patch
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build -j"$(nproc)"
sudo install -m755 build/hyprlock /usr/local/bin/hyprlock
```
