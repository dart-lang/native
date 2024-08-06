
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

_56: Date.now,
_58: s => new Date(s * 1000).getTimezoneOffset() * 60 ,
_60: () => {
          let stackString = new Error().stack.toString();
          let frames = stackString.split('\n');
          let drop = 2;
          if (frames[0] === 'Error') {
              drop += 1;
          }
          return frames.slice(drop).join('\n');
        },
_64: () => {
      // On browsers return `globalThis.location.href`
      if (globalThis.location != null) {
        return globalThis.location.href;
      }
      return null;
    },
_65: () => {
        return typeof process != "undefined" &&
               Object.prototype.toString.call(process) == "[object process]" &&
               process.platform == "win32"
      },
_79: s => JSON.stringify(s),
_80: s => printToConsole(s),
_81: a => a.join(''),
_82: (o, a, b) => o.replace(a, b),
_84: (s, t) => s.split(t),
_85: s => s.toLowerCase(),
_86: s => s.toUpperCase(),
_87: s => s.trim(),
_91: (s, p, i) => s.indexOf(p, i),
_92: (s, p, i) => s.lastIndexOf(p, i),
_93: (s) => s.replace(/\$/g, "$$$$"),
_94: Object.is,
_95: s => s.toUpperCase(),
_96: s => s.toLowerCase(),
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
_135: Function.prototype.call.bind(DataView.prototype.setUint8),
_136: Function.prototype.call.bind(DataView.prototype.getInt8),
_138: Function.prototype.call.bind(DataView.prototype.getUint16),
_140: Function.prototype.call.bind(DataView.prototype.getInt16),
_142: Function.prototype.call.bind(DataView.prototype.getUint32),
_144: Function.prototype.call.bind(DataView.prototype.getInt32),
_150: Function.prototype.call.bind(DataView.prototype.getFloat32),
_152: Function.prototype.call.bind(DataView.prototype.getFloat64),
_159: f => finalizeWrapper(f, function(x0,x1,x2) { return dartInstance.exports._159(f,arguments.length,x0,x1,x2) }),
_160: (x0,x1) => globalThis.addFunction(x0,x1),
_161: x0 => globalThis.removeFunction(x0),
_162: (x0,x1) => x0.mkdir(x1),
_163: (x0,x1,x2) => x0.writeFile(x1,x2),
_164: (x0,x1) => x0.unlink(x1),
_165: (x0,x1,x2) => x0.analyzePath(x1,x2),
_166: (x0,x1,x2) => x0.writeFile(x1,x2),
_169: x0 => x0.cwd(),
_180: () => globalThis.FS,
_204: (c) =>
              queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
_207: (s, m) => {
          try {
            return new RegExp(s, m);
          } catch (e) {
            return String(e);
          }
        },
_208: (x0,x1) => x0.exec(x1),
_209: (x0,x1) => x0.test(x1),
_210: (x0,x1) => x0.exec(x1),
_211: (x0,x1) => x0.exec(x1),
_212: x0 => x0.pop(),
_218: o => o === undefined,
_219: o => typeof o === 'boolean',
_220: o => typeof o === 'number',
_222: o => typeof o === 'string',
_225: o => o instanceof Int8Array,
_226: o => o instanceof Uint8Array,
_227: o => o instanceof Uint8ClampedArray,
_228: o => o instanceof Int16Array,
_229: o => o instanceof Uint16Array,
_230: o => o instanceof Int32Array,
_231: o => o instanceof Uint32Array,
_232: o => o instanceof Float32Array,
_233: o => o instanceof Float64Array,
_234: o => o instanceof ArrayBuffer,
_235: o => o instanceof DataView,
_236: o => o instanceof Array,
_237: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
_240: o => o instanceof RegExp,
_241: (l, r) => l === r,
_242: o => o,
_243: o => o,
_244: o => o,
_245: b => !!b,
_246: o => o.length,
_249: (o, i) => o[i],
_250: f => f.dartFunction,
_251: l => arrayFromDartList(Int8Array, l),
_252: (data, length) => {
          const jsBytes = new Uint8Array(length);
          const getByte = dartInstance.exports.$uint8ListGet;
          for (let i = 0; i < length; i++) {
            jsBytes[i] = getByte(data, i);
          }
          return jsBytes;
        },
_253: l => arrayFromDartList(Uint8ClampedArray, l),
_254: l => arrayFromDartList(Int16Array, l),
_255: l => arrayFromDartList(Uint16Array, l),
_256: l => arrayFromDartList(Int32Array, l),
_257: l => arrayFromDartList(Uint32Array, l),
_258: l => arrayFromDartList(Float32Array, l),
_259: l => arrayFromDartList(Float64Array, l),
_260: (data, length) => {
          const read = dartInstance.exports.$byteDataGetUint8;
          const view = new DataView(new ArrayBuffer(length));
          for (let i = 0; i < length; i++) {
              view.setUint8(i, read(data, i));
          }
          return view;
        },
_261: l => arrayFromDartList(Array, l),
_262:       (s, length) => {
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
_263:     (s, length) => {
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
_264:     (s) => {
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
_267: l => new Array(l),
_271: (o, p) => o[p],
_275: o => String(o),
_280: x0 => x0.index,
_282: x0 => x0.length,
_284: (x0,x1) => x0[x1],
_287: x0 => x0.flags,
_288: x0 => x0.multiline,
_289: x0 => x0.ignoreCase,
_290: x0 => x0.unicode,
_291: x0 => x0.dotAll,
_292: (x0,x1) => x0.lastIndex = x1,
_294: (o, p) => o[p],
_297: v => v.toString()
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

