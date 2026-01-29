# Ray Marching Demo

Unity上でRay MarchingのShaderを簡単に記述できる教材パッケージです！  
「アバターなんもわからん集会」での講演で使用する教材として作成されました！  

![](Images/Slide_1.png)  
![](Images/Slide_2.png)  
![](Images/Slide_3.png)  
![](Images/Slide_4.png)  
![](Images/Slide_5.png)  
![](Images/Slide_6.png)  

## 📝 概要

`RayMarchingDemo.cginc`ヘッダファイルを使うだけで、簡単にRay MarchingのShaderの記述を体験できます！  
複雑な数学的処理やRay Marchingのアルゴリズムはヘッダファイル側で実装されているので、ユーザーはマクロを使用するだけでRay Marching Shaderを作成できちゃいます！

## ✨ 特徴

- **簡単導入**: ヘッダファイルをインクルードするだけで使用可能です！
- **マクロベース**: 3つのマジックマクロで簡単にRay Marchingを実装できます！
- **サンプル豊富**: ハート、星、トーラスなどの3D SDF関数を収録しています！
- **教育向け**: 初心者でもRay Marchingの概念を理解しやすい構造になっています！

## 🚀 使い方

### 基本的な使用方法

1. Shaderファイルに`RayMarchingDemo.cginc`をインクルード！
2. 以下の3つのマクロを適切な場所に配置！
3. 以上！

```glsl
// 頂点シェーダの構造体に追加
MAGIC_VERTEX_STRUCTURE

// 頂点シェーダ内で呼び出し
MAGIC_VERTEX

// フラグメントシェーダ内で呼び出し
MAGIC_FRAGMENT
```

### サンプルコード

```glsl
#include "RayMarchingDemo.cginc"

struct v2f
{
    float4 vertex : SV_POSITION;
    MAGIC_VERTEX_STRUCTURE  // ローカル座標を保持
};

v2f vert (appdata v)
{
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    MAGIC_VERTEX  // ローカル座標を渡す
    return o;
}

fixed4 frag (v2f i) : SV_Target
{
    fixed4 col = fixed4(1,1,1,1);
    MAGIC_FRAGMENT  // Ray Marchingを実行
    return col;
}
```

## 📦 パッケージ内容

### 提供されるSDF関数

- `Heart3d()` - 3Dハート形
- `Star3d()` - 3D星形
- `torus()` - トーラス（ドーナツ形状、アニメーション付き）

### シェーダープロパティ

- `_Color`: 基本色
- `_ShapeShift`: 形状のモーフィング (0.0 - 1.0) 
- `SHAPE_CHANGE`: シェーダーキーワード（形状切り替え用）

### ユーティリティ関数

- `bevel()` / `bevelMax()`: アーティファクト除去用のベベル処理
- `getNormal()`: 法線計算（ライティング用）
- `distanceField()`: シーン全体の距離関数

## 🎓 学習ポイント

### Ray Marchingの基本

このパッケージでは以下のRay Marchingの基本概念を学べます：

1. **距離場（SDF）**: シーンを距離関数で表現
2. **レイステップ**: 距離に応じてレイを進める
3. **法線計算**: 距離場の勾配から法線を算出
4. **ライティング**: Lambert反射とAmbient Occlusion

### コードリーディングポイント

```glsl
// Ray Marchingのメインループ
for (int i = 0; i < maxIteration; ++i)
{
    p = ro + rd * t;           // 現在の位置を計算
    d = distanceField(p);      // シーンとの距離を取得
    t += d;                    // 距離分レイを進める
    if (d < precision || t > maxDistance) break;
}
```

## 🛠️ 動作環境

- Unity 2022.3.22f1 以降
- .NET Framework 4.7.1
- VRChat SDK (任意)

## 📂 プロジェクト構造

```
Assets/Appletea's Item/Ray Marching Demo/v1.0/Sample/
├── Shader/
│   ├── RayMarchingDemo.cginc       # Ray Marchingヘッダファイル
│   └── Demo Shader v1.0.shader     # サンプルShader
├── Material/
│   └── Sample.mat                  # サンプルマテリアル
├── Prefab/
│   └── Sample.prefab               # サンプルプレハブ
└── Scenes/
    └── Sample.unity                # サンプルシーン
```

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 👤 作者

**あっぷるてぃー**

- GitHub: [@Appletea0673](https://github.com/Appletea0673)
- X: [あっぷるてぃー](https://x.com/Appletea_VRC)

## 🙏 謝辞

このプロジェクトは「アバターなんもわからん集会」での講演資料として作成されました！

---

## 📚 参考資料

Ray Marchingについて詳しく学びたい方は、以下のリソースをご参照ください！

- [Inigo Quilez - Distance Functions](https://iquilezles.org/articles/distfunctions/)
- [Ray Marching and Signed Distance Functions](https://jamie-wong.com/2016/07/15/ray-marching-signed-distance-functions/)
