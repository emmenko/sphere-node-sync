# sphere-node-sync

[![Build Status](https://secure.travis-ci.org/emmenko/sphere-node-sync.png?branch=master)](http://travis-ci.org/emmenko/sphere-node-sync) [![NPM version](https://badge.fury.io/js/sphere-node-sync.png)](http://badge.fury.io/js/sphere-node-sync) [![Coverage Status](https://coveralls.io/repos/emmenko/sphere-node-sync/badge.png?branch=master)](https://coveralls.io/r/emmenko/sphere-node-sync?branch=master) [![Dependency Status](https://david-dm.org/emmenko/sphere-node-sync.png?theme=shields.io)](https://david-dm.org/emmenko/sphere-node-sync) [![devDependency Status](https://david-dm.org/emmenko/sphere-node-sync/dev-status.png?theme=shields.io)](https://david-dm.org/emmenko/sphere-node-sync#info=devDependencies)

Collection of Sync components for SPHERE.IO entities

## Table of Contents
* [Getting Started](#getting-started)
* [Documentation](#documentation)
  * [Rest connector](#rest-connector)
  * [Error handling](#error-handling)
  * [Methods](#methods)
    * [buildActions](#buildactions) 
    * [get](#get)
    * [update](#update)
* [Supported Update actions](#supported-update-actions)
  * [ProductSync](#productsync) 
  * [OrderSync](#ordersync) 
  * [InventorySync](#inventorysync) 
* [Updater components](#updater-components)
* [Contributing](#contributing)
* [Releasing](#releasing)
* [Styleguide](#styleguide)
* [License](#license)

## Getting Started
Install the module with: `npm install sphere-node-sync`

```javascript
var sync = require('sphere-node-sync')

// or require one of the Sync components
var product_sync = require('sphere-node-sync').ProductSync
var order_sync = require('sphere-node-sync').OrderSync
var inventory_sync = require('sphere-node-sync').InventorySync
```

## Documentation
The module exposes many collection `Sync` objects, _resource-specific_, and it's used to build update actions for that resource. Available resources are:

- *products* - `ProductSync`
- *orders* - `OrderSync`
- *inventory* - `InventorySync`

> All `Sync` objects share the same implementation, only the _mapping_ of the *actions update* is resource-specific. **I will assume from now on (for the sake of simplicity) that the `Sync` is either an instance of one of the resources listed above.**


### Rest connector
It's _recommended_ to use the `Sync` together with the [sphere-node-connect](https://github.com/emmenko/sphere-node-connect) module.
In fact it has a dependency to the module so that you can make requests by using the instance of the `Rest` class.

```javascript
// https://github.com/emmenko/sphere-node-connect#documentation
var sync = new Sync({}) // refer to the Rest arguments (sphere-node-connect) if you want to pass options

sync._rest.GET ...
```
> The **credentials are optional**, if you don't pass them the `Rest` connector won't be instantiated.


### Error handling
Please refer to the connector [documentation](https://github.com/emmenko/sphere-node-connect#error-handling).


### Methods

Following methods are accessible from the object.

#### `buildActions`
There is basically one main method `buildActions` which expects **2 valid JSON objects**, here is the signature:

```javascript
buildActions = function(new_obj, old_obj) {
  // ...
  return this;
}
```
The method returns a reference to the current object `Sync`, so that you can chain it with optional methods `get` and `update`.
> The important data (actions, etc) is stored in a variable of the Sync class and accessible with `_data`.

#### `get`
It's a wrapper of the `_data` object and returns one of its values given a `key`.
Available keys:
```javascript
_data = {
  "update": {...}, // the update actions object, undefined if there is no update
  "updateId": "..." // the id of the product to be updated
}

// example
sync.get() // return _data.update
sync.get("updateId") // return _data.updateId

// or chain it
sync.buildActions(new_obj, old_obj).get()
```

#### `update`
It will send an update request to the resource, using the `id` of the `old_obj` passed in the `buildActions`.
It's recommended to use it by chaining it with the `buildActions` method.
If a callback is given it will pass [following arguments](https://github.com/mikeal/request#requestoptions-callback): `(error, response, body)`.

> Note that `body` is automatically parsed as JSON object.
> It will throw an `Error` if no credentials were given to the `Sync` object.

```javascript
sync.buildActions(new_obj, old_obj).update(function(e, r, b){
  // do something
})
```

## Supported Update actions
Currently following actions are supported

### ProductSync

- `changeName` - field `name`
- `changeSlug` - field `slug`
- `setDescription` - field `description`
- `removePrice` - field `prices` (all variants)
- `addPrice` - field `prices` (all variants)
- `setAttribute` - field `attributes` (all variants)
- `setAttributeInAllVariants` - field `attributes` (all variants)

### OrderSync

- `changeOrderState` - field `orderState`
- `changePaymentState` - field `paymentState`
- `changeShipmentState` - field `shipmentState`
- `setReturnShipmentState` - field `shipmentState`
- `setReturnPaymentState` - field `paymentState`
- `addReturnInfo` - field `returnInfo`

### InventorySync

- `addQuantity` - field `quantityOnStock` is more than before
- `removeQuantity` - field `quantityOnStock` is less than before
- `setExpectedDelivery` - field `expectedDelivery`


## Updater components
Besides the `Sync` components, the module exposes `Updater` components which are basically resource-specific classes that add functionalities around the syncing.

Current updaters exposed are:

- `CommonUpdater` (abstract class that holds common functionalities like *progressBar*, **logs**, etc)
- `InventoryUpdater` (abstract class that includes some common functions to handle inventory updates)


## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```

## Styleguide
We <3 CoffeeScript! So please have a look at this referenced [coffeescript styleguide](https://github.com/polarmobile/coffeescript-style-guide) when doing changes to the code.

## License
Copyright (c) 2013 Nicola Molinari
Licensed under the MIT license.
