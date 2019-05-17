# regdiffexplorer

Windows Registry Differences Explorer
Use this tool to explore as well as find differences between the two loaded registeries.

## Getting Started

You must have perl installed on the system to run this tool

### Prerequisites

Two registry export files to compare/analyze and perl

### Capabilities

The following capabilities are available.

* Explore ALL Registry Keys (PRE & POST subkey/values): When exploring a registry key, a display of associated key/values from both, pre and post, registry files are displayed on a single screen.
* Explore Modified Keys Only (PRE & POST subkey/values): This option ONLY brings up registry keys that were modified. Upon selecting any of the displayed keys, ONLY modifed subkey and values will be displayed. If a registry key has ten different subkeys and associated values, and only two of the subkey values changed, selecting this option will bring the main registry key and subsequently selecting the registry key will display the two changed subkeys/values.
* Display New Keys Only (Key:Subkey:Value): Lists any registry keys that were not present in the pre.reg file but present in post.reg export. Display the entire list of new additions of key:subkey:value.
* Display Deleted Keys Only (Key:Subkey:Value): Displays deleted keys:subkeys:value
* Search Keys/Subkeys/Values with text pattern on PRE: Fast and powerful registry search option that searches across the registry key, subkey, and subkey values. Seach is performed on the pre.reg file (first argument passed during execution.)
* Search Keys/Subkeys/Values with text pattern on POST: Seach on the post.reg file (second argument).
* Export all differences to file (mod/add/rem): Export all difference to a file. Please specify full path with write permissions to export differences.

### Example

```
> perl regdiffexplorer.pl pre.reg post.reg


==========================================================================
            Windows Registry Diff Explorer [v1.5]
              By ANA Technology Partner
                https://anapartner.com
         Feedback/Contact: support@anapartner.com
===========================================================================

Copyright 2019 ANA Technology Partner, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License https://www.gnu.org/licenses/ for more details.

===========================================================================

REGISTRY EXPORT (PRE): pre.reg ...Loaded.
REGISTRY EXPORT (POST): post.reg ...Loaded.

Select an option from the below menu:

[1]. Explore ALL Registry Keys (PRE & POST subkey/values)
[2]. Explore Modified Keys Only (PRE & POST subkey/values)
[3]. Display New Keys Only (Key:Subkey:Value)
[4]. Display Deleted Keys Only (Key:Subkey:Value)
[5]. Search Keys/Subkeys/Values with text pattern on PRE
[6]. Search Keys/Subkeys/Values with text pattern on POST
[7]. Export all differences to file (mod/add/rem)
[8]. Help

[x]. Exit

Enter Choice:

``` 

## Authors

* **ANA Partner** - *Initial work* - [ANA Partner](https://anapartner.com)

## License

This project is licensed under the GNU General Public License - see the [LICENSE.md](LICENSE.md) file for details
