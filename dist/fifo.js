
(function(root, factory) {
  var fifo, _fifo;
  if (typeof define !== "undefined" && define !== null ? define.amd : void 0) {
    return define(factory);
  } else {
    _fifo = root.fifo;
    fifo = root.fifo = factory();
    return fifo.noConflict = function() {
      root.fifo = _fifo;
      return fifo;
    };
  }
})(this, function() {
  return function(namespace) {
    var data, removeFirstIn, save, trySave;
    data = JSON.parse(localStorage.getItem(namespace) || '{"keys":[],"items":{}}');
    trySave = function() {
      var json;
      json = JSON.stringify(data);
      try {
        localStorage.setItem(namespace, json);
      } catch (error) {
        if (error.name === 'QUOTA_EXCEEDED_ERR') {
          return false;
        } else {
          throw new Error(error);
        }
      }
      return true;
    };
    removeFirstIn = function() {
      var firstIn, removedItem;
      firstIn = data.keys.pop();
      removedItem = {
        key: firstIn,
        value: data.items[firstIn]
      };
      delete data.items[firstIn];
      return removedItem;
    };
    save = function() {
      var removed;
      removed = [];
      while (!trySave()) {
        if (data.keys.length) {
          removed.push(removeFirstIn());
        } else {
          throw new Error("All items removed from " + namespace + ", still can't save");
          break;
        }
      }
      return removed;
    };
    return {
      set: function(key, value, onRemoved) {
        var removed;
        data.items[key] = value;
        data.keys.unshift(key);
        removed = save();
        if (onRemoved && removed.length) onRemoved.call(this, removed);
        return this;
      },
      get: function(key) {
        if (key) {
          return data.items[key];
        } else {
          return data.items;
        }
      },
      remove: function(victim) {
        var index, suspect, _len, _ref;
        _ref = data.keys;
        for (index = 0, _len = _ref.length; index < _len; index++) {
          suspect = _ref[index];
          if (!(suspect === victim)) continue;
          data.keys.splice(index, 1);
          break;
        }
        delete data.items[victim];
        save();
        return this;
      },
      empty: function() {
        data = {
          keys: [],
          items: {}
        };
        save();
        return this;
      }
    };
  };
});
