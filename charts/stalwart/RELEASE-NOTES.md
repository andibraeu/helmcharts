## ⚠️ Breaking change: Stalwart v1

Chart 2.x ships Stalwart v1. Stalwart v1 uses a new database layout and
**cannot open a v0.16 data store** – upgrading in place from chart 1.x leaves
the server unable to start.

### Upgrading from chart 1.x

1. Make sure you are running chart `1.0.7` (Stalwart v0.16.27), the version
   required by the migration tool.
2. Create a new, empty data store and migrate your data with
   [stalwart-migrate](https://github.com/stalwartlabs/stalwart-migrate)
   (see the [official migration guide](https://stalw.art/docs/migration/upgrade-0-16/)).
3. Point `config` to the new data store and upgrade to chart 2.x.
4. Start once with `extraEnv.STALWART_UPDATE_ROLE_PERMISSIONS: "true"` so the
   default roles get the permissions added in v1, then remove the variable.

To stay on v0.16, pin the chart to `1.0.7` or set `image.tag: v0.16.27`.

See the chart README ("Upgrading from 1.x to 2.0") for details.
