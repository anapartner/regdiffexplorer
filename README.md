# regdiffexplorer

Windows Registry Differences Explorer
Use this tool to explore as well as find differences between the two loaded registeries.

## Getting Started

You must have perl installed on the system to run this tool

### Prerequisites

Two registry export files to compare/analyze and perl

### Capabilities

The following capabilities are available

* Explore ALL Registry Keys (PRE & POST subkey/values)
* Explore Modified Keys Only (PRE & POST subkey/values)
* Display New Keys Only (Key:Subkey:Value)
* Display Deleted Keys Only (Key:Subkey:Value)
* Search Keys/Subkeys/Values with text pattern on PRE
* Search Keys/Subkeys/Values with text pattern on POST
* Export all differences to file (mod/add/rem)

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
