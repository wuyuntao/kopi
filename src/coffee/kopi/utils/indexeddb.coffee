kopi.module("kopi.utils.indexeddb")
  .define (exports) ->

    win = window
    indexedDB = win.indexedDB or win.mozIndexedDB or win.webkitIndexedDB or win.msIndexedDB
    IDBTransaction = win.IDBTransaction or win.webkitIDBTransaction or win.msIDBTransaction
    exports.indexedDB = indexedDB
    exports.IDBTransaction = IDBTransaction
