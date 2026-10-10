# TDD コード例

## Red-Green-Refactor サイクル

### 1. Red（レッド）— 失敗するテストを書く

```typescript
test("2つの数を足すことができる", () => {
  const calculator = new Calculator();
  expect(calculator.add(2, 3)).toBe(5);
});
// → Calculatorクラスは存在しない → テスト失敗
```

### 2. Green（グリーン）— テストが通る最小限のコードを書く

```typescript
class Calculator {
  add(a: number, b: number): number {
    return 5; // 仮実装
  }
}
```

### 3. Refactor（リファクタ）— 重複を排除し、コードを改善

```typescript
class Calculator {
  add(a: number, b: number): number {
    return a + b; // 三角測量で正しい実装へ
  }
}
```

## 三角測量の例

```typescript
// 1つ目のテスト
test("2 + 3 = 5", () => {
  expect(calculator.add(2, 3)).toBe(5);
});
// 仮実装: return 5;

// 2つ目のテスト（三角測量）
test("3 + 4 = 7", () => {
  expect(calculator.add(3, 4)).toBe(7);
});
// → 一般化が必要になり return a + b; へ
```

## テストの粒度

```typescript
// ❌ 粗すぎる
test("ユーザー管理機能", () => { /* 全部テスト */ });

// ✅ 適切
test("ユーザーを作成できる", () => { ... });
test("ユーザーを更新できる", () => { ... });
```

## 明確なテスト名

```typescript
// ❌ 曖昧
test("ユーザーテスト", () => {});

// ✅ 明確
test("有効な名前でユーザーを作成できる", () => {});
test("空の名前でユーザー作成時にエラーが発生する", () => {});
```
