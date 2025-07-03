import { expect, test } from 'vitest';

function sum(a: number, b: number): number {
  return a + b;
}

test('sum function should return 3', () => {
  expect(sum(1, 2)).toBe(3);
});
