# SwiftStringComposition

`SwiftStringComposition` provides some features that handles `String` as a collection of lines.


# Requirements

- Swift 5, 6
- macOS(>=10.15) or Linux

## Dependencies

<!-- SWIFT PACKAGE DEPENDENCIES MERMAID START -->
```mermaid
---
title: StringComposition Dependencies
---
flowchart TD
  swiftranges(["Ranges<br>@4.0.1"])
  swiftstringcomposition["StringComposition"]
  swiftunicodesupplement(["UnicodeSupplement<br>@2.0.0"])
  yswiftextensions(["yExtensions<br>@2.0.0"])

  click swiftranges href "https://github.com/YOCKOW/SwiftRanges.git"
  click swiftunicodesupplement href "https://github.com/YOCKOW/SwiftUnicodeSupplement.git"
  click yswiftextensions href "https://github.com/YOCKOW/ySwiftExtensions.git"

  swiftstringcomposition --> yswiftextensions
  swiftunicodesupplement ----> swiftranges
  yswiftextensions ----> swiftranges
  yswiftextensions --> swiftunicodesupplement


```
<!-- SWIFT PACKAGE DEPENDENCIES MERMAID END -->


# Usage

```Swift
import StringComposition


let string = """
#include <stdio.h>

int main(int argc, char* argv[]) {
printf("Hello, world!");
return 0;
}
"""

var lines = String.Composition(string)
lines.shiftRight(1, in: 3...4)
lines.indent = .spaces(count: 4)

print(lines.description)
/*
#include <stdio.h>

int main(int argc, char* argv[]) {
    printf("Hello, world!");
    return 0;
}
*/

```



# License

MIT License.  
See "LICENSE.txt" for more information.


