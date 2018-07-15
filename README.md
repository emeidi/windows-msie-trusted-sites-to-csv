# windows-msie-trusted-sites-to-csv
Dumps all Trusted Sites configured in Microsoft Internet Explorer in a CSV file

I wrote this script to perform an analysis of all entries of Trusted Sites on my work laptop.

The PowerShell script also dumps the type of each entry:

1. Intranet zone
1. Trusted Sites zone
1. Internet zone
1. Restricted Sites zone

Last but not least, the script also indicates whether the entry points to the public Internet based on the .tld used.
