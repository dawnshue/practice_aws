insertdeal() {
local ifolder=$1
local ilastday=$2
local ipartition=$3
local partname=$(echo $ipartition | cut -d'=' -f1)
local dealname=$(echo $ipartition | cut -d'=' -f2)
echo "$(date) INSERTDEAL | ifolder=$ifolder; ilastday=$ilastday; partition=$ipartition"
currfile=$(s3cmd ls $S3DIR/$ifolder/day=$ilastday/$ipartition/ | head -n1 | rev | cut -d'/' -f1 | rev)
echo "$(date) $ifolder | lastday=$ilastday; dealname=$dealname; currfile=$currfile"
s3cmd get -f $S3DIR/$ifolder/day=$ilastday/$ipartition/$currfile $currfile
#Add date and dealname to data
cat $currfile | sed -e "s/$/\t$ilastday\t$dealname/g" >$tempfile
echo "$(date) $tempfile length:$(cat $tempfile | wc -l)"
#Delete duplicate data in psql table
echo "$(date) PSQL: DELETE FROM $ifolder WHERE $partname='$dealname' AND day='$ilastday'"
psql -d psqldb -c "DELETE FROM $ifolder WHERE $partname='$dealname' AND day='$ilastday'"
#Insert data from tempfile
echo "$(date) PSQL: COPY $ifolder FROM '$tempfile' DELIMITER E'\t' CSV;"
psql -d psqldb -c "COPY $ifolder FROM '$tempfile' DELIMITER E'\t' CSV;"
#Clean Up
rm -fv $currfile $tempfile
}
######################
######################
# INSERT FUNCTION
######################
insert() {
local ifolder=$1
local ilastday=$2
echo "$(date) INSERT | ifolder=$ifolder; ilastday=$ilastday"
s3cmd ls $S3DIR/$ifolder/day=$ilastday/ | grep DIR
s3cmd ls $S3DIR/$ifolder/day=$ilastday/ | grep DIR | rev | cut -d'/' -f2 | rev | while read partition
do
echo "$(date) INSERT -> INSERTDEAL | ifolder=$ifolder; ilastday=$ilastday; partition=$partition"
insertdeal $ifolder $ilastday $partition
done
}
######################

get_casale_lostwins() {
local ilastday=$1
local ifolder='casale_lostwins'
echo "$(date) GETPVALUES | ifolder=$ifolder; ilastday=$ilastday"
currfile=$(s3cmd ls $S3DIR/$ifolder/day=$ilastday/ | head -n1 | rev | cut -d'/' -f1 | rev)
echo "$(date) $ifolder | lastday=$ilastday; currfile=$currfile"
if [[ ! $currfile == '' ]]; then
s3cmd get -f $S3DIR/$ifolder/day=$ilastday/$currfile $currfile
#Add date and dealname to data
cat $currfile | sed -e "s/$/\t$ilastday/g" | sed -e 's/"/""/g' >$tempfile
echo "$(date) $tempfile length:$(cat $tempfile | wc -l)"
#Delete duplicate data in psql table
echo "$(date) PSQL: DELETE FROM $ifolder WHERE day='$ilastday'"
psql -d psqldb -c "DELETE FROM $ifolder WHERE day='$ilastday'"
#Insert data from tempfile
echo "$(date) PSQL: COPY $ifolder FROM '$tempfile' DELIMITER E'\t' CSV;"
psql -d psqldb -c "COPY $ifolder FROM '$tempfile' DELIMITER E'\t' CSV;"
fi
}


