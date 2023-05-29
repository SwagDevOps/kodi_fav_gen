## Simple favourites generator for kodi

[Favourites][wiki/favourites] can be edited directly 
in the [``favourites.xml``][wiki/favourites.xml] file 
in the [``userdata``][wiki/userdata] folder.
``kodi-favgen`` provides a solution to generate ``favourites.xml`` files 
from small (and clean) YAML files. 

### Sample favourite YAML file

```yaml
---
name: France 2
thumb: france2
action: |
  ActivateWindow(10025,&quot;plugin://plugin.video.catchuptvandmore/resources/lib/channels/fr/francetv/channel_homepage/
  ?_pickle_=800595b8000000000000007d94288c075f7469746c655f948c2554c3a96cc3a9766973696f6e2064652072617474726170616765202d
  204672616e63652032948c065f617267735f945d948c116368616e6e656c732f6672616e63652d3294618c0b69735f706c617961626c6594898c09
  69735f666f6c64657294888c056f72646572944b028c0866726f6d5f66617694888c096974656d5f68617368948c20333063646533613030343561
  656333633130326631656330346438343361313794752e&quot;,return)
```

### Samples of use

```shell
# kodi-favgen directory='sample/favourites'
# kodi-favgen directory='sample/favourites' output='/dev/stdout'
# kodi-favgen directory='sample/favourites' thumbs-directory=../thumbs output='/dev/stdout'
# kodi-favgen directory='sample/favourites' tmpdir=sample/cache/ output='/dev/stdout'
```

``thumbs-directory`` is relative to ``directory``, 
unless the path is given as absolute.

``tmpdir`` must be an absolute path.

<!-- hyperlinks -->
[wiki/favourites]: https://kodi.wiki/view/Favourites
[wiki/favourites.xml]: https://kodi.wiki/view/Favourites.xml
[wiki/userdata]: https://kodi.wiki/view/Userdata
