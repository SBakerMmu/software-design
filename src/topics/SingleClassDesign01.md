# Design of a single class - Access control

In Java and other OO languages we write software in classes. Identifying appropriate classes is a big part of object-oriented design, but first we will work on the structure of a single class using the language features available in Java.

## Declaring and initialising fields and variables

Although you can declare fields and not initialise them, they are implicitly initialised to 0 in the case of primitive types and null in the case of reference types.

``` Java
class MyClass
{
    private int x; //A field of primitive type, which is an instance variable, implicitly initialized to 0;
    private int y = 10; //A field of primitive type, which is an instance variable, explicitly initialized to 10;
    private MyClass myClass1; A field of reference type, which is an instance variable, implicitly initialized to null;
    private MyClass myClass2 = new MyClass(); A field of reference type, which is an instance variable, explicitly initialized to an instance;
}
```
☑ Prefer explicit initialisation, because then your intention is clear - is the absence of initialisation by design or by accident?

Using explicit initialisation in the class declaration makes your intentions clear, as in this example

``` Java
class MyClass
{
    private int x = 0;
    private int y = 10;
    private MyClass myClass1 = null;
    private MyClass myClass2 = new MyClass();
}
```
The same is true for **local variables** - variables which are declared within methods, and only visible within the declaring method. Always initialize them.

``` Java
class MyClass
{
    ...
    double myMethod() {
        double val = 0.0; //val is declared and scoped to the method
    }

}
```
☑ Variables should have the tightest possible scope. Do not make what should be a local variable a field (instance variable).

``` Java
class MyClass
{
    private double x = 0;

    //If x is only used in this method and not part of the state of the object
    //it should just be a local variable.
    double area(double radius) {
         x = radius * radius;
         return x * Math.PI;
    }
}
```
This is better written as

``` Java
class MyClass
{
    double area(double radius) {
         double x = radius * radius;
         return x * Math.PI;
    }
}
```
## Suppliers and Clients

We write classes so that they supply useful functionality to other classes. Code that calls any **member** (fields or methods) of your class is called a **client** of your class. Conversely, your class is a **supplier** to a client.

The members you expose are the **application programming interface** or **API**  of your class. The use of the word interface is different to the Java `interface` keyword. The term interface in **application programming interface** means all the fields, methods and types that a developer needs to know in order to use your class and the term applies regardless if your class is a standard class, `extends` an abstract superclass or `implements` a Java interface.

> ☑ When writing classes that will be used by others, how the API works is a key part of software design process because it will determine how easily another developer can use your class. Whole books are written about what makes a good API, but you want to your API to cause other developers the least work as possible when using your class. Work here means both typing (the amount of code needed to be written) and cognitive work (how much effort it takes to understand what your class does).


## Minimising access to your class

When you create a class in Java you want to *hide* as much of its implementation as possible. This is so that we can change the implementation without *breaking* our client code because client code has used a method or accessed a field we now want to change.

Java provides mechanisms for access control, to prevent the users of a package or class from accessing unnecessary details of the implementation of that package or class. If access is permitted, then the accessed entity is said to be **accessible** (Oracle, 2024 Ch 6.6).

When you declare a new class in Java, you can indicate the level of access permitted to its members (fields and methods) and constructors. Java provides four levels of
**access specifiers**. Three of the levels must be explicitly specified

- `private`
- `protected`
- `public`

If no access specifier is used, then the member or constructor is implicitly `package private`.

`private` means that the member or constructor is only accessible within the declaring class.

`public`  means that the member or constructor is publicly accessible.

`protected` means that the member or constructor is only accessible to subclasses of the declaring class.

### Java packages

Java packages are containers for your classes, the package name being the first line of the .java file.

``` Java
package mypackage;

public class MyClass {
}
```
If you create a Java class without a package name, then you are using the **unnamed** or **default package** or which has no name. (Oracle, 2024 Ch 7.6).

Java packages have multiple purposes.

- Packages avoid name conflicts. On any large system sooner or later you would get two different classes or interfaces that need the same name. By putting classes and interfaces within packages, you prevent naming conflicts because the class name actually becomes `packagename.classname` or `packagename.interfacename`. Package names are a kind of **namespace** - a namespace is a prefix to a name. An example of namespacing is internet domain names. Without using the domain name as a namespace, every website would need to have unique page names - most universities have a `/study` page, but the domain name `https://www.mmu.ac.uk` acts as a namespace so that the study page in `https://www.mmu.ac.uk/study` is distinguished from the study page at `https://www.birmingham.ac.uk/study`.

- Packages avoid source code file conflicts. Java files can contain at most one public class and the (case-sensitive) filename must match the name of the public class. To prevent having to have two .java files of the same name in the same directory the directory structure on disk also matches the package structure (packages can contain sub packages).

- Packages avoid .class file conflicts. When a Java file is compiled, each of the classes it defines is compiled into a separate .class file. However, when the runtime wants to load a class with a package it will attempt to load the class from a subdirectory corresponding to the package path.

- Packages provide access control. A class or interface is accessible outside the package that declares it only if the class or interface is declared `public`.

### Package Naming and Organisation

Java package names are lower cased to avoid conflict with the names of classes or interfaces.

In a student project your Java main file (typically) does not live in a package (which puts it in the unnamed package), but the other classes that make up your program should go into packages, for example you might create packages named:

`service` (contains your service classes)

`util` (contains your utility classes)

> ☠ Note that Oracle owns all the packages beginning `java` or `sun` so don't use those names for your packages.

In professional Java programming, it is a convention to use a reversed domain name as a package prefix (the assumption being that a domain name is unique in the world), for example if you owned the domain `example.com` then your packages might be

`com.example.myapp.service`

`com.example.myapp.util`

### Packages for Access Control
From the point of view of class design it is the access control we are mainly interested in. Consider the following example:

Anything declared `public` can be accessed from different classes and different packages. In this example we have  a public field and a public method in a public class.

``` Java
package mypackage;
 public class MyClass {
    public String myClassField = "";

    public void MyMethod()
    {
        //implementation

    }
}
```
We could use the fully qualified name `mypackage.MyClass` to access the public methods of MyClass

```Java
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
        mypackage.MyClass myClass = new mypackage.MyClass();
        myClass.myClassField = "new value for myClassField";
        myClass.MyMethod();;
    }
}
```
Using the `import` simply tells the compiler to substitute `MyClass` in the code with the **fully qualified** name `mypackage.MyClass`. `import` provide access to all public classes and interfaces declared in a package.

``` Java
import mypackage.MyClass;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
        MyClass myClass = new MyClass();
        myClass.myClassField = "new value for myClassField";
        myClass.MyMethod();
    }
}
```
> ⚠ IntelliJ will usually provide a prompt to import the package if it sees a non fully qualified type identifier.

> ⚠ Behind the scenes, the Java compiler also automatically imports all public classes and interfaces declared in the predefined package `java.lang` because that package provides classes that are fundamental to the design of the Java programming language such as `String` and `Throwable`. See the documentation for the `java.lang` package for more detail.

## Package Private

Assuming we don't want to make some members of MyClass available, we can fix this by removing the `public` access from MyClass and its members.

However, when a class, constructor or member does not have an explicit access specification, it is **package-private** - which means that it is accessible to other classes in the same package.

> ☠ Note this code example will stack overflow if you run it - it's just to show the access rules

``` Java
package mypackage;

class MyPackagePrivateClass {

    String myClassField = "";

    void MyMethod()
    {
        MyOtherPackagePrivateClass myOtherClass  = new MyOtherPackagePrivateClass();
        myOtherClass.myOtherClassField = "new myOtherClassField value";
        myOtherClass.MyOtherClassMethod();

    }
}
```

``` Java
package mypackage;

class MyOtherPackagePrivateClass {
    String myOtherClassField = "";
    void MyOtherClassMethod()
    {
        MyPackagePrivateClass myClass  = new MyPackagePrivateClass();
        myClass.myClassField = "new myClassField value";
        myClass.MyMethod();
    }
}
```

The fields myOtherClassField and myClassField and methods MyMethod() and MyOtherMethod() are not accessible outside  the package, but are accessible to all classes inside the package.

This is easily fixed by making these members `private`.

``` Java
class MyPackagePrivateClass {

    private String myClassField = "";

    private void MyMethod()
    {
        MyOtherPackagePrivateClass myOtherClass  = new MyOtherPackagePrivateClass();
        myOtherClass.myOtherClassField = "new myOtherClassField value";
        myOtherClass.MyOtherClassMethod();

    }
}
```

When coding Java classes it is tempting just to make the class and all its members `public`, but this is making all of your implementation accessible, which means that any client can access any class or method, which means you will not be able to change them without (potentially) breaking the client.

Instead, if you initially make classes package private and all members `private` you will need to expose each class or member on an as needed basis.

- All `public` classes and their `public` members become the API *outside* the package.
- All `public` and package private classes and all package private and `public` members become the API *inside* the package.

## Fields

Providing direct access to fields either by making them public or package-private is bad design. It exposes internal implementation which you want to keep hidden, but also means that you have no control over any values set by the client.

For example a simple class representing a Product in an e-commerce site.

``` Java
public class Product {
    public double fullPrice;
    public double discount;
}
```
We have exposed our data directly to the client code, and the client will have to work out its own way of applying discount to the full price.

It is better design to make the fields private and then write methods to manage the access to the data. For example, we probably do not want to change the full price of a product but do want to apply a discount. Rather than just exposing fields, a better design is to provide an API that manages the process of changing a price.

``` Java

class Product {

    private final double fullPrice;
    private double discount = 0d;

    public Product(double fullPrice) {
        this.fullPrice = fullPrice;
    }

    public void setDiscount(double discount) {
        //do pre- and post-condition checks
        this.discount = discount;
    }

    public double getSellingPrice() {
        return fullPrice - discount;
    }
}
```
This seems a lot more work than just leaving the field open and public, but we have gained a lot. We have hidden the internal data fields (fullPrice and discount) from the client, so we can change their names and even their types. We have also we have provided the client with a nice API that means the client code does not have to repeat a common task such as applying a discount to work out the selling price.

## Static fields and Constants

An **instance variable** is a non-static field declared within a class. When the class is instantiated new instance variables created that uniquely belong to that instance.

Fields can be declared within a class with the keyword `static`. There is a single instance (called the **class instance**) within the whole program which is shared between all instances of that class.

Static (class variables) are almost never good design.

- A class variable is **global state**. All objects share the same global value, so modifying a class variable affects all objects. This can lead to unintended side effects and errors because the value has been changed from outside the instance.
- A class variable is not thread safe - multiple threads can modify a class variable concurrently which again can lead to unintended side effects and errors.

Therefore, exposing static fields should be very a very exceptional design case.

There is one exception to this guidance, creating **constants** using `static final` fields. With constants the fact that there is only value in the entire program is desirable and the `final` declaration means that the value cannot be changed once it is initialized. Constants are safe because (as the name suggests) they can't be changed - they are **immutable**.

The Java naming convention for constants is to capitalize the name.

Using constants as opposed to just using hard coded numbers or strings in the code is to be encouraged as the constant name says what the purpose of the constant is.

``` Java
public class Product {

    private static final double NO_DISCOUNT = 0d;

     public void clearDiscount()
    {
        this.discount = NO_DISCOUNT; //Use of a named constant is clearer than just setting to 0.0d
    }
}
```

## Access control for subclasses

As well as hiding implementation from non-related classes, you also need to prevent unintended access to implementation by subclasses for the same reasons. Again the `private` access modifier keeps things private, but to make internals of the superclass accessible to subclasses the `protected` access modifier is used.

## Accessibility summary

|                                 | public | protected | default (package private) | private |
|---------------------------------|--------|-----------|---------------------------|---------|
| Same class                      | Yes    | Yes       | Yes                       | Yes     |
| Class in same package           | Yes    | Yes       | Yes                       | No      |
| Subclass in same package        | Yes    | Yes       | Yes                       | No      |
| Class in different package      | Yes    | No        | No                        | No      |
| Subclass in different package   | Yes    | Yes       | No                        | No      |


## More on Packages and Imports
Writing `import` declarations for specific classes or interfaces allows client code to use the class or interface name without qualification. These are called **single type** import declarations, and they specify the fully qualified name once, so you can use the simple class or interface many times in the Java file. Behind the scenes the compiler is still using fully qualified names, it is just using the import statement to generate the fully qualified name from the simple name.

We can get the compiler to do even more work by telling it to import class or interface names on demand. For example:

`import java.util.*;`

This is called a **type import on demand** declaration, and it tells the compiler to import all the public classes and interfaces (in this case from the java.util package).

By sensible use of imports, you gain all the access control benefits of putting classes into packages, but do not have to use fully qualified names in the source code files that use the package.

## Encapsulation and Information Hiding

Most discussions about object orientation talk about **encapsulation**.

Encapsulation at the class level is the hiding of the implementation (private fields, private methods) behind a public application programming interface (API). The internal implementation is not visible outside the class. The state of an object can only read or updated via the operations the public API.

A good design of a single class has a long-lived public application programming interface. The clients of that API do not need knowledge of or access to the internal fields and private methods, which means that the internal implementation can change providing the API still behaves as the client expects.

In Java, the concept of encapsulation scales up to the package. The public API offered by the package is the set of all public members and constructors of all public classes within the package, but the internal implementation of the package is hidden by using package private classes and package private or private members.

Encapsulation is one form of **information hiding** - a general principle in software engineering of creating any API (application programming interface) that hides design decisions and reveals as little as possible of the inner workings. Hiding implementation information in general allows us to work with something without having to know about all its internal details, and it should be possible to change the implementation without a need for the client code to change. Hiding implementation details behind an interface is one of the fundamental ideas of software engineering that helps us cope with complexity and change and the concept of information hiding (Parnas, 1972) pre-dates object-orientation.

## Class and Method Naming

Someone who is trying to use your code will want to understand what it does primarily through the class and method names you choose without having to look at the source code. This is why we are advised to use **intention revealing** names (Martin and Feathers 2009 Ch2), which means using class and method names that describe their effect and purpose. Very often we are writing code that models something in the real world, and we should make every effort to align the names in our code with the names of the things in the real world (or at least the real-world names provide some good ideas for the names in the code).

Fields and local variables (variables defined with methods) and variable names in for loops are names internal to the class implementation, and therefore should not be of concern to someone using your class, but they are of concern to anyone reading or modifying your class (including you), so equal care should be taken of private naming as public naming.

**Magic Numbers** or **Magic Strings** is the term given to literals used in code. They are called *magic* because they do not have a clear explanation of their meaning. We have already discussed the Java convention for defining constant values and a naming convention for naming the literal.

For example, instead of this:

````Java

for(int i = 0; i < 10; i++)
{
 //do something
}

````

use constants and intention revealing names.

````Java
//Important literal values are declared at the top of the class with some explanation as to what they are
private static final MAX_ITERATIONS = 10;

//Then use the constant, which provides both a name and single place to change the value.
for(int iteration = 0; i <MAX_ITERATIONS; iteration++)
{
 //do something
}

````

### Refactoring names

Modern IDEs have excellent facilities for renaming. As IDEs have an internal model of the code they will automatically find and change all the usages.

Generally, IDEs work with a right-click on the thing you want to rename and choose rename from the refactoring menu.

For example, see the IntelliJ documentation for the rename refactorings: https://www.jetbrains.com/help/idea/rename-refactorings.html


## Class Design Checklist

> ☑ Use intention revealing names everywhere.
>
> ☑ Put the fields and operations that read and modify those fields into the same class.
>
> ☑ Organise related classes into packages and organise the packages into a hierarchy.
>
> ☑ Ensure all fields within classes are `private`.
>
> ☑ Ensure that any fields with values that should not be changed once set are marked as `final`.
>
> ☑ You can always make a class or member more accessible in the future, but it's unlikely you can make something less accessible without breaking your client, so ensure only classes and methods that need to be public are `public` and check for methods that are have no access specifier (and are therefore package private) but only need to be `private` or `protected`.
