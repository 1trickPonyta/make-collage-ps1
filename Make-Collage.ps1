param ($In, $Out, $Size=3, $Background="white")

if ($In -eq $null) {
	$In = $args[0]
}
if ($Out -eq $null) {
	$Out = "$In.collage.png"
}

[Int] $width, [Int] $height = (magick identify -format "%[fx:w]x%[fx:h]" $In) -split "x"
$diagonal = [Math]::ceiling([Math]::sqrt($width*$width + $height*$height))

$temp = ".\.Make-Collage-temp"
rm -Recurse -Force $temp -ErrorAction SilentlyContinue
mkdir $temp | Out-Null

$rotation = @()
for ($i = 0; $i -lt $Size*$Size; $i++) {
	$name = "$temp\$i.png"
	$rotation += Get-Random -Maximum 360
	magick $In -background none -rotate $rotation[$i] -background none -gravity center -extent "$($diagonal)x$diagonal" $name
}

$command = "magick montage "

for ($m = 0; $m -lt 2; $m++) {
	for ($k = 0; $k -lt $Size; $k++) {
		for ($i = 0; $i -lt 2; $i++) {
			for ($j = 0; $j -lt $Size; $j++) {
				$name = "$temp\$($j+$k*$Size).png"
				$command += "$name "
			}
		}
	}
}

$command += "-tile x$($Size*2) -geometry -$([Math]::floor($diagonal/3))-$([Math]::floor($diagonal/3)) -background $Background $Out"

cmd /c $command
magick $Out -crop "$($diagonal/3*$Size)x$($diagonal/3*$Size)+$($diagonal/3*$Size/2)+$($diagonal/3*$Size/2)" $Out

rm -Recurse -Force $temp
