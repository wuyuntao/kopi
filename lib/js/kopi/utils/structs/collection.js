(function() {

  define("kopi/utils/structs/collection", function(require, exports, module) {
    var Collection;
    Collection = (function() {

      function Collection() {}

      /*
          @param {*} value Value to add to the collection.
      */


      Collection.prototype.add = function() {};

      /*
          @param {*} value Value to remove from the collection.
      */


      Collection.prototype.remove = function() {};

      /*
          @param {*} value Value to find in the tree.
          @return {boolean} Whether the collection contains the specified value.
      */


      Collection.prototype.has = function() {};

      /*
          @return {number} The number of values stored in the collection.
      */


      Collection.prototype.count = function() {};

      return Collection;

    })();
    return {
      Collection: Collection
    };
  });

}).call(this);
