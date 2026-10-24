# imagemagick image processor

## Convert images for posting to online marketplaces.

```bash
# ┌─ ImageMagick batch processor
# │              ┌─ write output as .jpg (originals kept)
# │              │           ┌─ remove EXIF/GPS/ICC metadata
# │              │           │      ┌─ fit within 2048px, only shrink, keep ratio
# │              │           │      │                    ┌─ JPEG quality (80–85 is the sweet spot)
# │              │           │      │                    │            ┌─ every .HEIC in this dir
```
```bash
  magick mogrify -format jpg -strip -resize "2048x2048>" -quality 82% *.HEIC
```

