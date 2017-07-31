/*
  @Author
  Ashish Kushwaha
 */


GLUquadric *quad;

//initialize planet
void initPlanet ()
{	
	quad = gluNewQuadric();
	return;
}
//draws planet
void drawPlanet()
{
	gluQuadricTexture(quad, 1);
	gluSphere(quad, 3.5, 30, 30);
	return;
}