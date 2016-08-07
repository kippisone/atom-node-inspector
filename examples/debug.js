'use strict';

let a = 'Apple';
let b = 'Banana';
let c = 'Coconut';

let arr = [];
arr.push(a);
arr.push(b);
arr.push(c);

for (let item in arr) {
  item += 'pi';
}

if (a === 'Applpi') {
  console.log('I eat ', a);
}
else {
  console.log('I dont\'t have an applepi :(');
}
