(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define("kopi/ui/groups", function(require, exports, module) {
    var Group, array, exceptions, klass, widgets;
    klass = require("kopi/utils/klass");
    exceptions = require("kopi/exceptions");
    array = require("kopi/utils/array");
    widgets = require("kopi/ui/widgets");
    Group = (function(_super) {

      __extends(Group, _super);

      Group.widgetName("Group");

      Group.configure({
        childClass: widgets.Widget
      });

      function Group(options) {
        Group.__super__.constructor.apply(this, arguments);
        this._keys = [];
        this._children = [];
      }

      Group.prototype.children = function() {
        return this._children;
      };

      /*
          Return child which is at index
      */


      Group.prototype.getAt = function(index) {
        return this._children[index];
      };

      Group.prototype.indexOf = function(child) {
        return array.indexOf(this._keys, this._key(child));
      };

      /*
          If a child widget is in the group
      */


      Group.prototype.has = function(child) {
        return array.indexOf(this._keys, this._key(child)) !== -1;
      };

      /*
          Add a child widget
      */


      Group.prototype.add = function(child, options) {
        if (options == null) {
          options = {};
        }
        return this.addAt(child, options, this._keys.length);
      };

      Group.prototype.addAt = function(child, options, index) {
        var self;
        if (options == null) {
          options = {};
        }
        if (index == null) {
          index = 0;
        }
        self = this;
        if (!child instanceof self._options.childClass) {
          throw new exceptions.ValueError("Child view must be a subclass of " + self._options.childClass.name);
        }
        if (self.has(child)) {
          throw new exceptions.ValueError("Already added!!!");
        }
        child.end(self);
        array.insertAt(self._keys, index, self._key(child));
        array.insertAt(self._children, index, child);
        self._appendChild(child);
        return child;
      };

      /*
          Remove a child widget
      */


      Group.prototype.remove = function(child) {
        var index;
        index = array.indexOf(this._keys, this._key(child));
        return this.removeAt(index);
      };

      /*
          Removes the child at the specified position in the group.
      */


      Group.prototype.removeAt = function(index) {
        if (!((0 <= index && index < this._keys.length))) {
          throw new exceptions.ValueError("Child view does not exist");
        }
        child.destroy();
        array.removeAt(this._keys, index);
        array.removeAt(this._children, index);
        return this;
      };

      /*
          Remove all child widgets
      */


      Group.prototype.empty = function() {
        var child, _i, _len, _ref;
        _ref = this._children;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          child.destroy();
        }
        array.empty(this._keys);
        return array.empty(this._children);
      };

      /*
          Append child to wrapper element
      
          TODO Insert child according to its index
      */


      Group.prototype._appendChild = function(child) {
        var self;
        self = this;
        if (self.initialized) {
          child.skeletonTo(self._wrapper());
        }
        if (self.rendered) {
          return child.render();
        }
      };

      Group.prototype._key = function(child) {
        return child.guid;
      };

      Group.prototype.onskeleton = function() {
        this._skeletonChildren();
        return Group.__super__.onskeleton.apply(this, arguments);
      };

      Group.prototype.onrender = function() {
        this._renderChildren();
        return Group.__super__.onrender.apply(this, arguments);
      };

      Group.prototype._skeletonChildren = function() {
        var child, wrapper, _i, _len, _ref, _results;
        wrapper = this._wrapper();
        _ref = this._children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(child.skeleton().element.appendTo(wrapper));
        }
        return _results;
      };

      Group.prototype._renderChildren = function() {
        var child, _i, _len, _ref, _results;
        _ref = this._children;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          child = _ref[_i];
          _results.push(child.render());
        }
        return _results;
      };

      /*
          Return the element which child elements should be appended to
      
          Override in subclasses if neccessary
      */


      Group.prototype._wrapper = function() {
        return this.element;
      };

      return Group;

    })(widgets.Widget);
    return {
      Group: Group
    };
  });

}).call(this);
