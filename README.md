scdlr.sh
===========

[Scdlr](http://jpablobr.github.com/scdlr) is a SoundCloud shell DJs tracks
downloader that supports resume via `Curl(1)`

![scdlr](https://github.com/jpablobr/scdlr/raw/master/scdlr.png)

Installation
------------

        git clone https://github.com/jpablobr/scdlr.git

        cd scdlr

        make && sudo make install

Usage
-----

From the command-line:

Append a URL to the download.list

        scdlr.sh -a URL

Download all URLs on the download.list

        scdlr.sh -s

Download.list
-------------

Just ad the DJs profile URL to the `download.list` as such:

    http://soundcloud.com/bassbintwins
    http://soundcloud.com/bassnectar
    # http://soundcloud.com/dirty-talk
    # http://soundcloud.com/funckarma
    ...

Notice it's also possible in the `ARTISTS_LIST` to *comment* out DJs
that already been downloaded but do not wish to remove them from the
list because maybe later on you'll want to re-download their
music... Though, `Curl(1)` will handle all the download `resuming`
functionality anyway! :).

TODO
----

Better handling for the download.list file

Copyright:
----------
(The MIT License)

Copyright 2011 Jose Pablo Barrantes. MIT Licence, so go for it.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, an d/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
