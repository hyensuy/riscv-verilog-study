//////////////////////////////////////////////////////////////////
// Main Function
//////////////////////////////////////////////////////////////////


int function2(int p) {
	int r;

	r = p + 5;

	return r + p;
}


int function1(int a, int b) {
	int i, x;

	x = (a + b) * (a -b); //multiply (RV21Im)

	for (i = 0; i < a; i++)
		x = x + function2(b + i);

	return x;
}

int main(void)
{
	int y;
  y = function1(3,1);

  while(1){
  }
}

