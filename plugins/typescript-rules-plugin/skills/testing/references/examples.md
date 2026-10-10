# テストコード例

## 目次

- [フラット構造の例](#フラット構造の例)
- [条件分岐の禁止例](#条件分岐の禁止例)
- [パラメータ化テストの例](#パラメータ化テストの例)
- [トートロジーテスト・無価値テストの禁止例](#トートロジーテスト無価値テストの禁止例)
- [ディレクトリ構成](#ディレクトリ構成)

## フラット構造の例

```typescript
// ✅ 推奨: describeなしのフラット構造
test("有効な認証情報でログインするとトークンが返る", () => {
  const result = login({ email: "test@example.com", password: "valid" });
  expect(result.token).toBeDefined();
});

test("無効なメールではValidationErrorが発生する", () => {
  expect(() => login({ email: "invalid", password: "valid" }))
    .toThrow(ValidationError);
});
```

## 条件分岐の禁止例

```typescript
// ❌ 悪い例: if で分岐するテスト
test("数値を分類する", () => {
  const values = [0, 1, -1];
  for (const v of values) {
    const result = classify(v);
    if (v === 0) {
      expect(result).toBe("zero");
    } else if (v > 0) {
      expect(result).toBe("positive");
    } else {
      expect(result).toBe("negative");
    }
  }
});

// ✅ 良い例: test.each で分割
test.each([
  [0, "zero"],
  [1, "positive"],
  [-1, "negative"],
])("classify(%i) は %s を返す", (value, expected) => {
  expect(classify(value)).toBe(expected);
});
```

## パラメータ化テストの例

```typescript
test.each([
  [1, 2, 3],
  [5, 5, 10],
  [-1, 1, 0],
])("add(%i, %i) は %i を返す", (a, b, expected) => {
  expect(add(a, b)).toBe(expected);
});
```

## トートロジーテスト・無価値テストの禁止例

```typescript
// ❌ 悪い例: オブジェクト生成後にプロパティを確認するだけ（言語仕様が保証する）
test("ユーザーが作成される", () => {
  const user = createUser({ name: "太郎", age: 20 });
  expect(user.name).toBe("太郎");
  expect(user.age).toBe(20);
});

// ❌ 悪い例: 配列操作の結果を確認するだけ
test("アイテムが追加される", () => {
  const items: string[] = [];
  items.push("apple");
  expect(items).toHaveLength(1);
  expect(items[0]).toBe("apple");
});

// ❌ 悪い例: 定数の値を確認するだけ
test("デフォルトのタイムアウトが設定されている", () => {
  expect(DefaultTimeout).toBe(3000);
});

// ✅ 良い例: ロジック（計算・変換・分岐）の振る舞いをテスト
test("未成年ユーザーにはアルコール購入権限がない", () => {
  const user = createUser({ name: "太郎", age: 17 });
  expect(user.canPurchaseAlcohol()).toBe(false);
});

// ✅ 良い例: ビジネスルールに基づく変換をテスト
test("カートの合計が1000円以上で送料が無料になる", () => {
  const cart = createCart([
    { name: "商品A", price: 600 },
    { name: "商品B", price: 500 },
  ]);
  expect(cart.shippingFee()).toBe(0);
});
```

### 判定基準

テストを書く前に「このテストが失敗したら何のバグが見つかるか？」を自問する。答えが「言語やランタイムの不具合」しかない場合、そのテストは不要。

## ディレクトリ構成

テストファイルの配置は以下のいずれか（プロジェクトに合わせて選択）。

### コロケーション（テスト対象と同一フォルダ）

```
src/
├── user-login.ts
├── user-login.validation.test.ts
├── user-login.error.test.ts
├── user-registration.ts
├── user-registration.test.ts
└── helpers/
    ├── user-utils.ts
    └── user-utils.test.ts
```

### __tests__ ディレクトリ

```
__tests__/
├── user-login.validation.test.ts
├── user-login.error.test.ts
├── user-registration.test.ts
└── helpers/
    └── user-test-utils.ts
```
