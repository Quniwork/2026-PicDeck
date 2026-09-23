# PicDeck device updates

After changing the PicDeck app, build and install the latest app on all three development targets before handing work back:

- iPhone 18 Pro simulator: `609C7D8C-52C7-4AED-AB7C-DF5ADE289D0D`
- iPhone 14 Pro Max simulator: `A6068813-D220-4272-B019-9DAA57BE0934`
- Physical iPhone 14 Pro Max: `00008120-0001241C01EB401E`

Use bundle ID `com.picdeck.app`. Preserve app data; do not erase, uninstall, or reset a device to update. Build the simulator and physical-device variants as needed. Install and launch on the simulators; install on the physical phone when connected and available. If a device is unavailable or locked, complete the other installations and report the exact remaining step. Do not wait for a confirmation to perform this routine update.

Verify each change automatically with a build and focused checks appropriate to the change. For visual layout changes, inspect both simulator sizes and both appearance modes when relevant. The user has authorized this routine verification and device update without a new confirmation each time.
