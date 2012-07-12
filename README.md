Cinegraphr
==========

Cinegraphr is a [Cinemagraph™](http://cinemagraphs.com/) generator written in Ruby with [RubyMotion](http://rubymotion.com).

This is mostly a proof of concept trying different techniques and frameworks with **RubyMotion**, due to a lack of time I can't go further alone so contribution and help is definitively welcome!

While still a work in progress most of the capture, masking, filtering and gif generation is working.

Getting started
---------------
To build and test Cinegraphr on the simulator you will need XCode installed, a valid [RubyMotion](http://rubymotion.com) licence and a free iOS developer account.

If you want to deploy on your device you will have to enroll in the iPhone developer program and setup your device for development.

To build and start the simulator, simply type `rake` and wait.

Todo
----
* Cleanup and stabilize capture
* Write more filters
* UI to apply filters
* Push generated Cinemagraph™ somewhere in addition to saving them locally (an OAuth2 stub is present but needs much more work)
* Finalize playback
* Social, social, social!

Contributing
------------
Go ahead, fork it and make something awesome!

Licences
--------
All the code is released under the MIT licence:

* [www.opensource.org/licenses/MIT](http://www.opensource.org/licenses/MIT)

Icons and other graphical resources are © [EPIC Agency](http://epic/net) and can't be used outside of this project for any purpose whatsoever without prior written permission.