_What this does_
This script uses Google Language APIs to translate your `Localizable.strings` files into whatever languages you (and Google) would like to support. 

_How to use it_
Visit the Google API Console at https://code.google.com/apis/console/. Register your version of the script as a new project. Google will give you an API key. Take this key, put it into `config.yaml.example`, and remove the `example` from the end of the filename. Google has a 100,000 query limit on it's language API, which is way more than you'll need, I think. Technically Google does not support automated translation scripts like this one, so your API key may get banned. If you've already got one you're using, don't use it.

To start with, you should have already set your project up for localization by using Apple's `NSLocalizedString(@"key", @"This is a comment")` macro and extracted those keys using the [genstrings][1] tool.

The source language should be specified by editing the `source_lang` variable, it defaults to English. You should always use the 2 letter code for your source and destination fields.

Every laguange you would like to translate into should have an associated `.lproj` folder in your directory. The script will read those folders and use them to determine the destination languages.

Run the script from the directory containing your source and destination `.lproj` folders, and the keys will be used to automatically translate your strings.

_Bugs_
 * The script doesn't correctly handle non-alphanumeric characters.
 * There is the destination files are overwritten by default, there is no support for partially translated files, so be carefull if you are adding new strings to your source file.
 * I'm sure there's a ton more problems, this is the first draft. Good luck!



[1]: http://developer.apple.com/library/ios/#documentation/Cocoa/Conceptual/LoadingResources/Strings/Strings.html%23//apple_ref/doc/uid/10000051i-CH6-SW5