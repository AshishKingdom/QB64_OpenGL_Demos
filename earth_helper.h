/*
  @Author
  Ashish Kushwaha
 */


GLUquadric *quad;

//initialize earth
void initEarth ()
{	
	quad = gluNewQuadric();
	return;
}
//draws earth
void drawEarth()
{
	gluQuadricTexture(quad, 1);
	gluSphere(quad, 3.5, 30, 30);
	return;
}