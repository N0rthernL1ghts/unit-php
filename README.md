# unit-php
Alpine based Docker image for nginx-unit with PHP module

Ready-to-use images:
```
nlss/unit-php
```

Currently under active maintenance, so to be considered as unstable.


#### Caveats
- Comes with PHP ZTS (Zend Thread Safety) enabled. The reason behind is that official PHP image, doesn't support PHP embed on Alpine based images. See: https://github.com/docker-library/php/pull/1355. It does, however on ZTS Alpine images.
