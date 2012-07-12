ae
--

**Release Cinegraphr as an Open Source project**

The capture is somewhat stabilized. Limited to 2seconds of recording
this avoid exploding the memory when generating the GIF.

**Know issues**:

* The masking step seems to have a massive performance problem. Can't
  find why, it worked before™
* Geolocation could use some stability enhancements
* OAuth2 suckso

**Changelog**:

* Re-done preview/masking to avoid scaling issues
* Correct image filter texting binding
* Filter updates
* Optimized resources
* Full port to GPUImage
* Avoid NSDate/Time bug in RM for TMP file generation
* Rewrote capture to use a movie clip at temp data
* Retina images

ad
--

Protect & log out of bounds error in animation drawing

ac
--


ab
--

Restored TestflightSDK

aa
--

**This is a major release**: the capture process has been completely rewrote to better integrate filters and avoid too much context switching. Still no remote operations for now, it's coming next.

**Know issues**:

* memory might be a problem. Cinegraphr could crash from time to time, especially on "large" (3+ sec) movies.
* OpenGL context is a bit capricious. The issue is two-fold:
    * Sometimes you'll get a black screen after the capture. This means game-over, restart the app
    * The context gets invalidated after the preview generation, you have to press play to view the changes applied

**Changelog**:

* Name change: All references to Cinegraph have been changed to Cinegraphr (this means a new app, uninstall the other one)
* Rewrote the capture to support CIImages instead of CGImages
* Using GLKView to present captured images instead of UIImageView
* Refactored the capture and editor to be more seamless
* Implemented "tap-to-focus", double-tap to record from now on
* Most UI resources are now retina
* Reworked filters, implemented the burn filter (default and only one for now)
* Prerender animation with filters for preview (once started, the cost over simple compositing is negligible so why not)
* cleanup, progress hud, ...

a9
--

* Fixed hidding UI on tap when editing mask
* RM 0.42

a8
--

* Added new beta tester (THE creator of RubyMotion)

a7
--

* Added full support for TestFlight SDK. Allows me to view
  sessions/crashreport more easilly. No other changes.

a6
--

* Fully rewrote gif generation to use CoreImage instead of CoreGraphics (allowing filter use)
* Apply sepia filter (because I can)

**Know issues**
Because of the way CoreImage is used there is a high memory penalty. If
your Cinemagraph is longer than 2-3 seconds it might crash.
This will corrected in the next build.

a5
--

* Correct saving graphs cache.
* Save relative path for graphs to survive application update

a4
--

* Save generated gifs to documents and allow iTunes sharing
* First run screen & OAuth2 login (hidden for now)
* Misc bug fixes
* RM 0.41-pre7. Fixes memory related crashes at last

a3
--

* RM 0.41-pre4. Fixes most crashes and should behave correctly while
  recording

a2
--

* Automatic testflight deployment

9f
--

* Reverted to RM 0.41-pre2 because of the crash during recording.

9c
--

* Oups, forgot to remove test images

9a
--

* Build with the latests version of RubyMotion. Should solve some memory related crashes.

96
--

* New build for Kevin and Benoit. No changes

2
-

Here's the first useable build.

Important!

* iOS5 ONLY!!!!!!
* It ***WILL*** crash. Sometimes often sometimes less often. If you can reproduce it, please try to reduce it as much as you can.
* The freeze frame selector is a bit hard to reach but once you got it it should be fine. Please insist.
* At the masking step one tap hides the UI. Another tap brings it back.
* Geotagging works but not sharing.
* There is a working viewer. Basic but enough for now.
* Right now images aren't uploaded anywhere (that's ok) but only stored in the app ***cache***. This is very important to note because the cache can be cleaned for many different reasons (update, freeing space, …). Pictures ***will be erased*** that's a given. Don't film childhood memories for now.

What I need:
* Mostly UX remarks on the workflow.

Enjoy,
Hugues
