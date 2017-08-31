
void 
GLoutput(GLfloat x, GLfloat y, char *text)
{
  char *p;

  glPushMatrix();
  glTranslatef(x, y, 0);
  for (p = text; *p; p++)
    glutStrokeCharacter(GLUT_STROKE_ROMAN, *p);
  glPopMatrix();
}