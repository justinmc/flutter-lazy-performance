# Flutter Lazy Performance

Examples of widgets extending off-screen and various ways of handling this in a performant way.  Demos with "naive" in the title optimize nothing at all, and they probably shouldn't be used except in trivial cases. Other examples attempt various performance improvements and trade offs.

This repo comes from a [talk](https://www.youtube.com/watch?v=qax_nOpgz7E) at Google I/O 2021.

Check out the live demo at: [https://justinmc.github.io/flutter-lazy-performance/](https://justinmc.github.io/flutter-lazy-performance/).

Thanks to the Marty McFly asset from Rive: [https://rive.app/community/52-69-marty-animation/](https://rive.app/community/52-69-marty-animation/).

## Notes
 * `InteractiveViewer.builder`, used in several of the examples here, was not available in Flutter's stable channel at the time of I/O (May 2021), but was available in dev and stable.  To check if your Flutter build has `InteractiveViewer.builder`, be sure you have commit https://github.com/flutter/flutter/commit/a8e41f8206133012056b02595111efe94537a816, which is from PR https://github.com/flutter/flutter/pull/80166.
 * When deploying the live demo on Github Pages, the index.html file must be updated to set a non-root path (see more in the [docs](https://flutter.dev/docs/development/ui/navigation/url-strategies)).

![Screenshot of menu](https://raw.githubusercontent.com/justinmc/flutter-lazy-performance/main/screenshots/menu.png?raw=true)
![Screenshot of list](https://raw.githubusercontent.com/justinmc/flutter-lazy-performance/main/screenshots/1d.png?raw=true)
![Screenshot of grid](https://raw.githubusercontent.com/justinmc/flutter-lazy-performance/main/screenshots/2d.png?raw=true)
![Screenshot of procedural generation demo](https://raw.githubusercontent.com/justinmc/flutter-lazy-performance/main/screenshots/proc_gen.png?raw=true)
