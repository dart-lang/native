typedef struct {
    int m_red;
    int m_green;
    int m_blue;
} Color;


typedef struct {
    float x, y, z;
    Color color;
} Vertex;

typedef struct {
    float x, y;
} Vector2;

typedef struct {
    float x, y, z;
} Vector3;

typedef struct {
    float x, y, z, w;
} Vector4;

typedef struct {
    float m[4][4];
} Matrix4x4;

int doNothing(double dumInput, unsigned int dumInput2) {
  return 0;
}

int doNothingToStruct6(Matrix4x4 dumInput) {
  return 0;
}
