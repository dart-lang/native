
// `modulePromise` is a promise to the `WebAssembly.module` object to be
//   instantiated.
// `importObjectPromise` is a promise to an object that contains any additional
//   imports needed by the module that aren't provided by the standard runtime.
//   The fields on this object will be merged into the importObject with which
//   the module will be instantiated.
// This function returns a promise to the instantiated module.
export const instantiate = async (modulePromise, importObjectPromise) => {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + js;
    }

    // Converts a Dart List to a JS array. Any Dart objects will be converted, but
    // this will be cheap for JSValues.
    function arrayFromDartList(constructor, list) {
      const exports = dartInstance.exports;
      const read = exports.$listRead;
      const length = exports.$listLength(list);
      const array = new constructor(length);
      for (let i = 0; i < length; i++) {
        array[i] = read(list, i);
      }
      return array;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {

_60: () => {
          let stackString = new Error().stack.toString();
          let frames = stackString.split('\n');
          let drop = 2;
          if (frames[0] === 'Error') {
              drop += 1;
          }
          return frames.slice(drop).join('\n');
        },
_79: s => JSON.stringify(s),
_80: s => printToConsole(s),
_81: a => a.join(''),
_91: (s, p, i) => s.indexOf(p, i),
_97: (a, i) => a.push(i),
_108: a => a.length,
_110: (a, i) => a[i],
_111: (a, i, v) => a[i] = v,
_114: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
_115: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
_116: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
_117: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
_118: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
_119: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
_120: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
_123: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
_124: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
_127: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
_131: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
_132: (b, o) => new DataView(b, o),
_134: Function.prototype.call.bind(DataView.prototype.getUint8),
_136: Function.prototype.call.bind(DataView.prototype.getInt8),
_138: Function.prototype.call.bind(DataView.prototype.getUint16),
_140: Function.prototype.call.bind(DataView.prototype.getInt16),
_142: Function.prototype.call.bind(DataView.prototype.getUint32),
_144: Function.prototype.call.bind(DataView.prototype.getInt32),
_150: Function.prototype.call.bind(DataView.prototype.getFloat32),
_152: Function.prototype.call.bind(DataView.prototype.getFloat64),
_159: (x0,x1) => globalThis.addFunction(x0,x1),
_160: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._160(f,arguments.length,x0,x1,x2) }),
_161: x0 => globalThis.removeFunction(x0),
_185: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_199: o => o === undefined,
_200: o => typeof o === 'boolean',
_201: o => typeof o === 'number',
_203: o => typeof o === 'string',
_206: o => o instanceof Int8Array,
_207: o => o instanceof Uint8Array,
_208: o => o instanceof Uint8ClampedArray,
_209: o => o instanceof Int16Array,
_210: o => o instanceof Uint16Array,
_211: o => o instanceof Int32Array,
_212: o => o instanceof Uint32Array,
_213: o => o instanceof Float32Array,
_214: o => o instanceof Float64Array,
_215: o => o instanceof ArrayBuffer,
_216: o => o instanceof DataView,
_217: o => o instanceof Array,
_218: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_222: (l, r) => l === r,
_223: o => o,
_224: o => o,
_225: o => o,
_226: b => !!b,
_227: o => o.length,
_230: (o, i) => o[i],
_231: f => f.dartFunction,
_232: l => arrayFromDartList(Int8Array, l),
_233: (data, length) => {
          const jsBytes = new Uint8Array(length);
          const getByte = dartInstance.exports.$uint8ListGet;
          for (let i = 0; i < length; i++) {
            jsBytes[i] = getByte(data, i);
          }
          return jsBytes;
        },
_234: l => arrayFromDartList(Uint8ClampedArray, l),
_235: l => arrayFromDartList(Int16Array, l),
_236: l => arrayFromDartList(Uint16Array, l),
_237: l => arrayFromDartList(Int32Array, l),
_238: l => arrayFromDartList(Uint32Array, l),
_239: l => arrayFromDartList(Float32Array, l),
_240: l => arrayFromDartList(Float64Array, l),
_241: (data, length) => {
          const read = dartInstance.exports.$byteDataGetUint8;
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, read(data, i));
          }
          return view;
        },
_242: l => arrayFromDartList(Array, l),
_243:       (s, length) => {
        if (length == 0) return '';

        const read = dartInstance.exports.$stringRead1;
        let result = '';
        let index = 0;
        const chunkLength = Math.min(length - index, 500);
        let array = new Array(chunkLength);
        while (index < length) {
          const newChunkLength = Math.min(length - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(s, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      }
      ,
_244:     (s, length) => {
      if (length == 0) return '';

      const read = dartInstance.exports.$stringRead2;
      let result = '';
      let index = 0;
      const chunkLength = Math.min(length - index, 500);
      let array = new Array(chunkLength);
      while (index < length) {
        const newChunkLength = Math.min(length - index, 500);
        for (let i = 0; i < newChunkLength; i++) {
          array[i] = read(s, index++);
        }
        if (newChunkLength < chunkLength) {
          array = array.slice(0, newChunkLength);
        }
        result += String.fromCharCode(...array);
      }
      return result;
    }
    ,
_245:     (s) => {
      let length = s.length;
      let range = 0;
      for (let i = 0; i < length; i++) {
        range |= s.codePointAt(i);
      }
      const exports = dartInstance.exports;
      if (range < 256) {
        if (length <= 10) {
          if (length == 1) {
            return exports.$stringAllocate1_1(s.codePointAt(0));
          }
          if (length == 2) {
            return exports.$stringAllocate1_2(s.codePointAt(0), s.codePointAt(1));
          }
          if (length == 3) {
            return exports.$stringAllocate1_3(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2));
          }
          if (length == 4) {
            return exports.$stringAllocate1_4(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3));
          }
          if (length == 5) {
            return exports.$stringAllocate1_5(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4));
          }
          if (length == 6) {
            return exports.$stringAllocate1_6(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5));
          }
          if (length == 7) {
            return exports.$stringAllocate1_7(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6));
          }
          if (length == 8) {
            return exports.$stringAllocate1_8(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7));
          }
          if (length == 9) {
            return exports.$stringAllocate1_9(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7), s.codePointAt(8));
          }
          if (length == 10) {
            return exports.$stringAllocate1_10(s.codePointAt(0), s.codePointAt(1), s.codePointAt(2), s.codePointAt(3), s.codePointAt(4), s.codePointAt(5), s.codePointAt(6), s.codePointAt(7), s.codePointAt(8), s.codePointAt(9));
          }
        }
        const dartString = exports.$stringAllocate1(length);
        const write = exports.$stringWrite1;
        for (let i = 0; i < length; i++) {
          write(dartString, i, s.codePointAt(i));
        }
        return dartString;
      } else {
        const dartString = exports.$stringAllocate2(length);
        const write = exports.$stringWrite2;
        for (let i = 0; i < length; i++) {
          write(dartString, i, s.charCodeAt(i));
        }
        return dartString;
      }
    }
    ,
_248: l => new Array(l),
_252: (o, p) => o[p],
_256: o => String(o),
_278: v => v.toString()
    };

    const baseImports = {
        dart2wasm: dart2wasm,


        Math: Math,
        Date: Date,
        Object: Object,
        Array: Array,
        Reflect: Reflect,
    };

    const jsStringPolyfill = {
        "charCodeAt": (s, i) => s.charCodeAt(i),
        "compare": (s1, s2) => {
            if (s1 < s2) return -1;
            if (s1 > s2) return 1;
            return 0;
        },
        "concat": (s1, s2) => s1 + s2,
        "equals": (s1, s2) => s1 === s2,
        "fromCharCode": (i) => String.fromCharCode(i),
        "length": (s) => s.length,
        "substring": (s, a, b) => s.substring(a, b),
    };

    dartInstance = await WebAssembly.instantiate(await modulePromise, {
        ...baseImports,
        ...(await importObjectPromise),
        "wasm:js-string": jsStringPolyfill,
    });

    return dartInstance;
}

// Call the main function for the instantiated module
// `moduleInstance` is the instantiated dart2wasm module
// `args` are any arguments that should be passed into the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

