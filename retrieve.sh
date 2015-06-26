#!/bin/bash

server="xfr.lax.dns.icann.org"
full_out_file="root.zone"
limited_out_file="root_limited.zone"

except_re='\tIN\t(DS|RRSIG|SOA)\t'

commit_message="auto"
dig_opt="+nomultiline +tries=1 +timeout=60"

cd `dirname $0` || exit 1

dig ${dig_opt} @${server} -t axfr .| /bin/grep -v '^;' > ${full_out_file}

soa_count=`grep -c -P "\tIN\tSOA\t" ${full_out_file}`
serial=`awk '/\tIN\tSOA\t/{print $7}' ${full_out_file} | head -1`

if [ "${soa_count}" -ne 2 ] ; then
	echo "zone data is invalid, abort."
	exit 1
fi

/bin/grep -v -P "${except_re}" ${full_out_file} | /bin/grep -v '^;' > ${limited_out_file}

git add ${full_out_file} ${limited_out_file} > /dev/null 2>&1
git commit -m "${serial}" > /dev/null 2>&1
git push -u origin master > /dev/null 2>&1
