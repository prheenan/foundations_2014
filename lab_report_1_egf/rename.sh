
dir="./TimePoint_72"
for f in ${dir}/*_[EFG]*; do
    # need the double quotes for literals for strings etc...
    mv "$f" "$f".blackout.tif;
done

for f in ${dir}/*_[BCD]*; do
    # need the double quotes for literals for strings etc...
    mv "$f" "$f".whiteout.tif;
done


