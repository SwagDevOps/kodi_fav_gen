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

Favourites support actions with a more concise (DRY) and declarative syntax.
Example with ``activate_window`` (as seen above):

```yaml
---
name: France 2
thumb: france2
action:
  type: activate_window
  value: |
    plugin://plugin.video.catchuptvandmore/resources/lib/channels/fr/francetv/channel_homepage/
    ?_pickle_=800595b8000000000000007d94288c075f7469746c655f948c2554c3a96cc3a9766973696f6e2064652072617474726170616765202d
    204672616e63652032948c065f617267735f945d948c116368616e6e656c732f6672616e63652d3294618c0b69735f706c617961626c6594898c09
    69735f666f6c64657294888c056f72646572944b028c0866726f6d5f66617694888c096974656d5f68617368948c20333063646533613030343561
    656333633130326631656330346438343361313794752e
```

### Samples of use

```shell
# kodi-favgen generate path='sample/favourites'
# kodi-favgen generate path='sample/favourites' output='/dev/stdout'
# kodi-favgen generate path='sample/favourites' thumbs-path=../thumbs output='/dev/stdout'
# kodi-favgen generate path='sample/favourites' tmpdir=sample/cache/ output='/dev/stdout'
```

## Actions

First argument is an action, available actions are:

| action       | description                                                                                                                    |
|--------------|--------------------------------------------------------------------------------------------------------------------------------|
| ``generate`` | Generate a favourites file.                                                                                                    |
| ``config``   | Display ``config`` with values from [``defaults``][SwagDevOps/kodi_fav_gen/config/defaults.rb], environment and CLI arguments. |   
| ``update``   | Update favourites using (`git`) version control, see: [``kodi_favourites``][SwagDevOps/kodi_favourites].                       |

## Variables

### ``generate``

| key           | defaults                                                       | description                                                                                                                                                                                                            | example                                         |
|---------------|----------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------|
| `path`        | __MUST BE SET__                                                | path to favourites files                                                                                                                                                                                               | ``${HOME}/.local/share/kodi_favgen/favourites`` |
| `thumbs-path` | `#{path}/../thumbs`                                            | ``thumbs-path`` is relative to ``path`` unless the path is given as absolute.                                                                                                                                          |                                                 |
| `output`      | `'.kodi/userdata/favourites.xml'`                              | [``favourites.xml``][wiki/favourites.xml] file in the [``userdata``][wiki/userdata] folder                                                                                                                             | ``${HOME}/.kodi/userdata/favourites.xml``       |
| `tmpdir`      | `"#{ENV[TMPDIR] \|\| ::Dir.tmpdir}/KodiFavGen.#{Process.uid}"` | [``TMPDIR``][wikipedia/tmpdir] is the canonical environment variable in Unix and POSIX that should be used to specify a temporary directory (see [The Open Group Base Specifications][opengroup/directory_structure]). | ``/tmp/KodiFavGen.1000``                        |

### ``update``

| key             | defaults        | description                      | example                              |
|-----------------|-----------------|----------------------------------|--------------------------------------|
| `update_path`   | __MUST BE SET__ | path to `git` root directory     | ``${HOME}/.local/share/kodi_favgen`` |
| `update_branch` | __MUST BE SET__ | branch used to update favourites | ``master``                           |

### Using variables in favourite files

File can use ERB template syntax, when using ``.yml.erb`` extension.
``variables`` are retrieved (as is) from Env Config.

Declare a variable in environment:

```shell
export KODI_FAVGEN__FILES_PATH='/home/john_doe/Public'
```

Or use the CLI parameters:

```shell
kodi-favgen path='sample/favourites' files-path='/home/john_doe/Public'
```

Retrieve and use the variable(s) in a YAML favourite file:

```yaml
# 000_files.yml.erb
name: Files
thumb: files
action:
  type: activate_window
  value: <%= files_path.inspect %>
```

<!-- hyperlinks -->

[wiki/favourites]: https://kodi.wiki/view/Favourites
[wiki/favourites.xml]: https://kodi.wiki/view/Favourites.xml
[wiki/userdata]: https://kodi.wiki/view/Userdata
[wikipedia/tmpdir]: https://en.wikipedia.org/wiki/TMPDIR
[opengroup/directory_structure]: https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xbd_chap10.html
[ruby/erb]: https://github.com/ruby/erb
[SwagDevOps/kodi_favourites]: https://github.com/SwagDevOps/kodi_favourites
[SwagDevOps/kodi_fav_gen/config/defaults.rb]: https://github.com/SwagDevOps/kodi_fav_gen/blob/master/lib/kodi_fav_gen/config/defaults.rb
