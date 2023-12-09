# LogCollector
This is a Powershell script to collect logs and back them up on a storage.  
<h1>Configuring The Script  </h1>
$storage variable with your destination path<br />
$hosts variable with your hosts to collect logs (you can declare them using hostname or fqdn)<br />
<h1>Using The Script  </h1>
- Should be scheduled to run every 30 minutes.<br />
- Should be scheduled only in 1 machine. We suggest to use a server that IS NOT a CORE or SQL machine.<br />
- Runs on powershell 3.0 or higher<br />
- Intended for Galaxy 5 (4.0.352, 4.0.376, 4.0.383).<br />
(it can run on other versions too, but you will have to modify the $LogDirectory variable)<br />
- By default, will purge all files older than 5 days.<br />
feel free to modify the last line on the script with a different number than 5, to fit your log backup retention policy.<br />
- Keep in mind that for zipping, the script uses -m0=lzma which means that the native Windows zip opener may not open these zip files (depends on the Windows version). Please open zip files with 7-zip.<br />
- Zip files are done by using 7-Zip binaries. 7-Zip is licensed under the GNU LGPL license. www.7-zip.org
