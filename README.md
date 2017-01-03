# SwiftyPapertrail
Papertrail and Syslog complaint subsystem for SwiftyLogger

## Requirements

* iOS 9.0+; may work with other NextStep style sysems but that isn't tested.  If you try it please let us know how it went!
* Xcode 8.0+; tested with Xcode 8.2

## Integration

Currently we support [CocoaPods](https://cocoapods.org/).  You can install the SwiftyPapertrail by adding the following to your `Podfile`.

```ruby
platform :ios, '9.0'
use_frameworks!

target 'MyApp' do
	pod 'SwiftyPaperTrail', :git => "https://github.com/Rhumbix/SwiftyPaperTrail", :tag => "v0.2.0"
end
```
## Usage
```swift
import SwiftyPapertrail

let loggerFactory = DefaultLoggerFactory().addSyslog( to: "syslog.example.com", tcp: 1234 )
let logger = loggerFactory.makeLogger()

logger.logInfo("Now logging over Syslog!")
```

### Customizing the behavior

The library is configurable if you chose to wire together the components yourself.  The class `SwiftyPaperTrail` is the `LoggerTarget` to integerate with _SwiftyLogger_.  Off of this class hangs a `messageFormatter` which should be of type `SyslogFormatter`.  The `SyslogFormatter` is responsible for generate the contents of a _syslog_ frame and should be compliant with RFC5424.  You may set the _facility_ on this class.

## Framework Goals
- pure Swift 3
- CocoaPod
- Fast
- Secure
- Easy to Use
- Tested
