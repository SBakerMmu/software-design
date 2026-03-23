# Polymorphism

Following on from our example, there is clearly a concept of discounted price which is the interplay of FullPrice and Discount. Now we can create a simple Value Object that encapsulates all the features of a discounted price.
In this example, we want to limit the discount in some way so that we don't discount beyond a set point. We are missing another concept, that of MinimumPrice as a companion to FullPrice.


``` Java
import java.util.Objects;

class FullPrice {
    public static final FullPrice ZERO = new FullPrice();

    private static final double NONE = 0.0d;
    final private double price;

    private FullPrice() {
        this(NONE);
    }

    public FullPrice(double price) {
        if (price < NONE) {
            //throw
        }
        this.price = price;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        FullPrice fullPrice = (FullPrice) o;
        return Double.compare(price, fullPrice.price) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(price);
    }

    @Override
    public String toString() {
        return "FullPrice{" +
                "price=" + price +
                '}';
    }

    public double get() {
        return price;
    }
}


class Discount {
    public static final Discount NO_DISCOUNT = new Discount();
    private static final double NONE = 0.0d;
    private final double discount;

    private Discount() {
        this(NONE);
    }

    public Discount(double discount) {
        //do the preconditions
        if (discount < NONE) {
            //throw an exception
        }
        this.discount = discount;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        Discount discount1 = (Discount) o;
        return Double.compare(discount, discount1.discount) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(discount);
    }

    @Override
    public String toString() {
        return "Discount{" +
                "discount=" + discount +
                '}';
    }

    public double get() {
        return discount;
    }
}

class MinimumPrice {
    public static final MinimumPrice NO_MINIMUM = new MinimumPrice();
    static final double NONE = 0.0d;
    final private double price;

    private MinimumPrice() {
        this(NONE);
    }

    public MinimumPrice(double price) {
        //do the preconditions
        if (price < NONE) {
            //throw exception
        }
        this.price = price;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        MinimumPrice that = (MinimumPrice) o;
        return Double.compare(price, that.price) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(price);
    }

    @Override
    public String toString() {
        return "MinimumPrice{" +
                "price=" + price +
                '}';
    }

    public double get() {
        return price;
    }
}

class DiscountedPrice {
    public static final DiscountedPrice ZERO = new DiscountedPrice();

    private final double price;

    private DiscountedPrice() {
        this(FullPrice.ZERO, MinimumPrice.NO_MINIMUM, Discount.NO_DISCOUNT);
    }

    public DiscountedPrice(FullPrice fullPrice, MinimumPrice minimum, Discount discount) {
        this(fullPrice.get(), minimum.get(), discount.get());
    }

    private DiscountedPrice(double fullPrice, double minimum, double discount) {
        this.price = fullPrice - discount;
        if (price < minimum) {
            //throw exception
        }
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        DiscountedPrice that = (DiscountedPrice) o;
        return Double.compare(price, that.price) == 0;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(price);
    }

    @Override
    public String toString() {
        return "DiscountedPrice{" +
                "price=" + price +
                '}';
    }

    public double get() {
        return price;
    }
}
```

The DiscountedPrice class contains the class invariant check, so any client of the DiscountedPrice is guaranteed that it is valid. Because the class is immutable, we can calculate the selling price once in the constructor and store the derived value. Here we are trading storage space vs computation time every time the value is calculated.

> Prefer optimising computation by calculating the value and storing it if there are a small number of instances that get used a lot. Optimise storage if there are many instances that get used a little.

We have now used Value Objects to model both full and discounted prices. However, the clients of Product don't care if the product is full price or discounted. The client just wants to know how much the Product costs.

The common operations we want from both FullPrice and DiscountedPrice is

- get a Price
- apply a Discount
- remove a Discount

The mechanism for getting common operations across different types is to define and implement an interface. Because we want these objects to be immutable, then the applyDiscount and removeDiscount operations return a new object that also implements the SellingPrice interface.

``` Java
interface SellingPrice {
    double get();

    SellingPrice applyDiscount(MinimumPrice minimum, Discount discount);

    SellingPrice removeDiscount();
}
```

The interface gets implemented by both FullPrice and DiscountedPrice

``` Java

import java.util.Objects;

class FullPrice implements SellingPrice {
    static final FullPrice ZERO = new FullPrice();
    private static final double NO_PRICE = 0.0d;
    final private double price;

    private FullPrice() {
        this(NO_PRICE);
    }

    public FullPrice(double price) {
        this.price = price;
    }

    @Override
    public boolean equals(Object o) {
        if (o instanceof SellingPrice other) {
            return price == other.get();
        } else return false;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(price);
    }

    @Override
    public String toString() {
        return "FullPrice{" +
                "price=" + price +
                '}';
    }

    @Override
    public double get() {
        return price;
    }

    @Override
    public SellingPrice applyDiscount(MinimumPrice minimum, Discount discount) {
        return new DiscountedPrice(this, minimum, discount);
    }


    @Override
    public SellingPrice removeDiscount() {
        return this;
    }
}


class DiscountedPrice implements SellingPrice {

    public final static DiscountedPrice ZERO = new DiscountedPrice();
    private final FullPrice fullPrice;
    private final Discount discount;
    private final double price;

    private DiscountedPrice() {
        this(FullPrice.ZERO, MinimumPrice.NO_MINIMUM, Discount.NO_DISCOUNT);
    }

    public DiscountedPrice(FullPrice fullPrice, MinimumPrice minimum, Discount discount) {
        this.fullPrice = fullPrice;
        this.discount = discount;
        this.price = fullPrice.get() - discount.get();
        //check invariant
        if (price < minimum.get()) {
            //throw exception
        }
    }

    @Override
    public boolean equals(Object o) {
        if (o instanceof SellingPrice other) {
            return price == other.get();
        } else return false;
    }

    @Override
    public int hashCode() {
        return Objects.hashCode(price);
    }

    @Override
    public SellingPrice applyDiscount(MinimumPrice minimum, Discount discount) {
        return new DiscountedPrice(this.fullPrice, minimum, discount);
    }

    @Override
    public SellingPrice removeDiscount() {
        return fullPrice;
    }

    @Override
    public String toString() {
        return "DiscountedPrice{" +
                "fullPrice=" + fullPrice +
                ", discount=" + discount +
                ", sellingPrice=" + price +
                '}';
    }

    @Override
    public double get() {
        return price;
    }

}
```

Finally, we reimplement Product using the SellingPrice interface

``` Java
class Product {

    private final MinimumPrice minimumPrice;
    private SellingPrice sellingPrice;

    public Product(FullPrice price, MinimumPrice minimumPrice) {
        this.sellingPrice = price;
        this.minimumPrice = minimumPrice;
    }

    public void applyDiscount(Discount discount) {

        sellingPrice = sellingPrice.applyDiscount(minimumPrice, discount);
    }

    public void removeDiscount() {

        sellingPrice = sellingPrice.removeDiscount();
    }

    public double getPrice() {
        return sellingPrice.get();
    }
}
```
Product maintains a private field of the type `SellingPrice`. When a Product is first created the instance variable is assigned an object of the `FullPrice` concrete type. When a discount is applied the instance variable is assigned an object of the `DiscountedPrice` concrete type. When a discount is removed the instance variable is reassigned an object of the `FullPrice` concrete type. All the logic required to apply and remove discounts is delegated to the concrete types.

This is an example of **Polymorphism**. The word polymorphism comes from the Greek word for "many forms". In the context of class design, replace the word `form` with `implementation` and you get many implementations of a set of common behavior - which implementation of the `SellingPrice` type is dependent on the concrete type assigned to the `sellingPrice` variable at the time.

You are using Polymorphism if an instance variable, a local variable or a  parameter in a method definition is of one type, but the supplied type (which in Java is either an
interface or a class) is different. The constraint is that the supplied type must **conform** (be compatible with) to the type of the field or parameter. In Java this means that the supplied concrete type must be a subtype of field or parameter type.

The thing that makes polymorphism so powerful is that the supplied concrete type can be changed at runtime based on some condition (a user input, a configuration change, logic in the program), including to a concrete type that didn't even exist when the client code was written.

If the concrete type conforms, the client code neither knows nor cares what concrete type has been supplied. This makes handling variation in behavior so much easier than writing procedural code that deals with variation using `if` or `switch` statements.

Making the simplest possible example, consider an abstract type `MyInterface` that defines a single operation `doSomething()`. We can write a client that takes some user input (such as a press of the A or B keys) to vary the implementation.

``` Java
interface MyInterface
{
  void doSomething();
}
```
Two classes ConcreteClassA and B are concrete implementations of MyInterface, providing their own implementations of the `doSomething` operation.

``` Java
class ConcreteClassA implements MyInterface
{
  @Override
  void doSomething(){
    //implementation using class A
  }
}

class ConcreteClassB implements MyInterface
{
  @Override
  void doSomething(){
    //implementation using class B
  }
}
```

The client code has a variable of the abstract type MyInterface. Initially this is supplied by A, but later can be switched to be supplied by B, changing the implementation at runtime.

``` Java
char keyPressed = //some code to get key press from the keyboard

MyInterface abstractMyInterface = (keyPressed == 'A') ?  new ConcreteClassA() : new ConcreteClassB();
abstractMyInterface.doSomething(); //get the A or B implementation depending on which key was pressed

```
 We could have done the same thing with inheritance

``` Java
class MyClass
{
  void doSomething(){
    //implement using base class
  }
}
```
Two classes ConcreteClassA and B are subclasses of ConcreteBaseClass, providing their own implementations of the `doSomething` operation.

``` Java
class MyClassA extends MyClass
{

 @Override
  void doSomething(){
    //implementation using class A
  }
}

class MyClassB extends MyClass
{
 @Override
  void doSomething(){
    //implementation using class B
  }
}
```
The client code has a variable of the type ConcreteBaseClass. Initially this is supplied by ConcreteBaseClass, but can later be supplied by subclass A, and later still be supplied by subclass B, changing the implementation at runtime.

``` Java
MyClass myClass = new MyClass();
myClass.doSomething(); //get the base class implementation as a default


//later on in the program execution
char keyPressed = //some code to get key press from the keyboard
myClass = (keyPressed == 'A') ? new MyClassA() : new MyClassB();
myClass.doSomething(); //get the A or B implementation depending on which key was pressed

```

Another term you may come across related to Polymorphism is **Dynamic Binding** or **Late Binding**. It means that the client class *binds* to the actual implementation only when the operation is called. In the example above there is no way the compiler can know in advance which implementation of the `doSomething()` method will be called because it is determined by a random key press. Instead, the Java runtime system needs to work this out. All it knows is the name of the operation, and it needs to find (bind to) the method implementation based on the type of the object it finds at runtime. The rules for this dynamic or late binding get complex when inheritance is involved - fortunately we don't have to worry about this and can rely on the Java runtime doing the right thing.

Most of the material from this point forward is based on Polymorphism using Java interfaces or inheritance. If you don't understand this chapter fully, write some examples or read other explanations of polymorphism because the concept and use of polymorphism is key to software design and being able to write maintainable and extensible code.


## Substitution and the Liskov Substitution Principle.

Polymorphism allows for different implementations to be used by the client - we can **substitute** one implementation for another. However, just because different implementations have the same operation names and signatures does not guarantee a good design. The different implementations must be **substitutable**, in other words the different implementations must perform the same task and not behave in a way that is unexpected by the client.

This is a subtle concept, but for example imagine that one of the implementations throws a different exception to the others - this would be a 'surprise' to the client - one implementation is behaving differently to another in a way that might break the client. It is up to author of any new implementations to ensure that the behavior of new implementation doesn't break the client or change the task being performed by the substitute.

This is called the **Liskov substitution principle** after Barbara Liskov, the computer scientist that first identified the principal.

> A principle that if S is a subtype of T, then objects of type T may be replaced with objects of type S (i.e., an object of type T may be substituted with any object of a subtype S) without altering any of the desirable properties of the client.

Some examples of the design thinking that is needed to ensure that a new implementation is substitutable:

- The new implementation must implement all the expected operations.

- The new implementation must maintain the expected pre-conditions. This means that any implementations can only *weaken* a pre-condition. For example, if the expected pre-condition that an argument was between 1 and 10, it would be a surprise to the client if a new implementation required the argument range to be between 2 and 5 (a stronger pre-condition). However, if the new implementation has a weaker pre-condition (accepts values between 1 and 100) that will be OK.

- The new implementation must maintain the expected post conditions. This means that any implementations can only *strengthen* a post-condition. For example, if the expected post-condition was than an operation returned a value between 1 and 10, it would be a surprise to the client if a new implementation returned an argument between 1 and 100. However, if a new implementation has a stronger post-condition (only returns values between 2 and 5) then that would be OK.

- The new implementation must maintain the expected class invariants. It would be a surprise to the client if a new implementation somehow maintained a weaker or different class invariant. However, if a new implementation maintains stronger invariants that would be OK.

Some symptoms of a substitution principle violation

- A new implementation throws an UnsupportedOperationException or some other unexpected exception for one or more of the operations.
- A new implementation throws more or different checked exception types to the other implementations.
- A new implementation demands stronger pre-conditions than the other implementations.
- A new implementation weakens the post-conditions compared to the other implementations.
- A new implementation does not preserve the same class invariants or preserves weaker class invariants.
- A new implementation is not thread safe when the other implementations are thread safe

If you can't maintain these rules then the new implementation is not a substitute - It's something else, and you have your design wrong.

## Guidance

The term 'interface' in Java programming can mean multiple things. An interface is the definition (but not necessarily the implementation) of one or more operations. Implementing an interface does not necessarily mean that you write a class that implements a Java interface (using the `interface` keyword). A concrete class implementing or overriding a method of a superclass is also implementing an interface

The two examples above demonstrated implementing an interface using a Java interface definition and class inheritance, so which method is best?

For reasons to be discussed later, there is a consensus that it is best to use Java interfaces to implement polymorphism. The guidance is to start with an interface, and later if it turns out there is a compelling benefit to using class inheritance, use the class inheritance hierarchy to implement the interface. For example,

``` Java

interface MyInterface
{
  void doSomething();
}

class MyClass implements MyInterface
{

  @Override
  void doSomething(){
    //implement using base class
  }
}

class MyClassA extends MyClass
{

 @Override
  void doSomething(){
    //implementation using class A
  }
}

class MyClassB extends MyClass
{
 @Override
  void doSomething(){
    //implementation using class B
  }
}
```
So the client ony uses the interface type.

``` Java
MyInterface myInterface = new MyClass();
myInterface.doSomething(); //get the base class implementation as a default


//later on in the program execution
char keyPressed = //some code to get key press from the keyboard
myInterface = (keyPressed == 'A') ? new MyClassA() : new MyClassB();
myInterface.doSomething(); //get the A or B implementation depending on which key was pressed

```

