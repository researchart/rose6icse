public void printClasspath() {

  //Get the System Classloader
  ClassLoader loader = ClassLoader.getSystemClassLoader();

  //Get the URLs
  URL[] urls = ((URLClassLoader) loader).getURLs();

  for (int i = 0; i < urls.length; i++) {
      System.out.println("    " + urls[i].getFile());
  }

  //Get the System Classloader
  loader = Thread.currentThread().getContextClassLoader();

  //Get the URLs
  urls = ((URLClassLoader) loader).getURLs();

  for (int i = 0; i < urls.length; i++) {
      System.out.println("    " + urls[i].getFile());
  }

}