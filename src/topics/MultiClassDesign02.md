# Design with multiple classes - Patterns for the co-ordination of multiple classes

In any software system you will need to co-ordinate the use of multiple classes.

One way of getting classes to collaborate is for classes take dependencies on other classes and call methods on those classes directly - many classes knowing about many other classes. We have discussed the issues with this above, not the least making it hard to test individual classes. The solution is to create additional classes that take responsibility for communicating between classes. There are a couple of design patterns that will help.

In this example we are putting products into an e-commerce basket, but also applying an automatic discount depending on the total value of the products in the basket. A user can also apply a discount code, and our requirement is that we grant the highest of the value-based discount or the discount granted by the discount code. In the examples we only have two classes, a `Basket` and a `Discounter` to co-ordinate, but the patterns apply when there are more classes to co-ordinate.

In both cases we want to provide a simple way for the client code to interact that hides the complexity of the interactions between the `Basket` and a `Discounter` making them easier to use. The client code only wants to do two things, add a `Product` to a `Basket` and apply a discount code provided by a user - the mechanics of how baskets and discounts interact should be hidden.

Our examples use a Value Object describing a Product.

```Java
class Product {

    private final String code;
    private final double  price;

    Product(String code, double price) {
        this.code = code;
        this.price = price;
    }

    public String getCode() {
        return code;
    }

    public double getPrice() {
        return price;
    }
}
```
## The Facade Pattern

The name **Facade** comes from the front of a building which presents a pleasing view and hiding the complex internal structure (the walls and floors) behind it. The Facade pattern does the same for software, a **Facade** provides a pleasing, high-level API that hides the complexities of an underlying set of classes, exposing only what's necessary for the client code.

In this example, we start with the two classes that we are going to put behind the Facade. The `Basket` class holds a list of products and provides a sum of product values less a discount. It is very simple and testable as it is not coupled to any particular way of determining the discount.

```Java
class Basket{

    private final List<Product> products = new ArrayList<>();
    double discount = 0;


    public void addProduct(Product product) {
        products.add(product);
    }

    public void removeProduct(Product product) {
        products.remove(product);
    }

    public double getTotal() {
        return products.stream().mapToDouble(Product::getPrice).sum();
    }

    public void setDiscount(double discount) {
        this.discount = discount;
    }

    public double getTotalWithDiscount() {
        return getTotal() * (1d - discount);
    }
}
```
The `Discounter` class set the highest of a 20% discount (if the total value is > 100) or a discount set by a discount code.  `Discounter` doesn't know anything about the `Basket`.

```Java
class Discounter  {

    private static final double discount0 = 0.0d;
    private static final double discount10 = 0.1d;
    private static final double discount20 = 0.2d;
    private static final double discount30 = 0.3d;
    private static final double discount40 = 0.4d;
    private static final double discount50 = 0.5d;

    private double discount = 0d;


    public double getDiscount() {
        return discount;
    }

    public void setTotal(double total) {
        double totalDiscount = total > 100d ? discount20 : discount0;
        discount = Math.max(discount, totalDiscount);
    }

    public void setDiscountCode(String code) {

        double codeDiscount = switch (code) {
            case "Discount10" -> discount10;
            case "Discount20" -> discount20;
            case "Discount30" -> discount30;
            case "Discount40" -> discount40;
            case "Discount50" -> discount50;
            default -> 0.0d;
        };

        discount = Math.max(discount, codeDiscount);
    }
}
```
We create a `Facade` class that provides a simple API across both the `Basket` and `Discounter` classes and manages their interactions.

```Java
class Facade {

    private final Basket basket = new Basket();
    private final Discounter discounter = new Discounter();

    public void addProduct(Product product) {
        basket.addProduct(product);
        discounter.setTotal(basket.getTotal());
        basket.setDiscount(discounter.getDiscount());
    }

    public void setDiscountCode(String code) {
        discounter.setDiscountCode(code);
        basket.setDiscount(discounter.getDiscount());
    }

    public double getTotalWithDiscount() {
        return basket.getTotalWithDiscount();
    }
}
```
The client code talks to the Facade rather than the objects behind the Facade.

```Java

Product a1 = new Product("A1", 50.0d);
Product a2 = new Product("A2", 250.0d);

Facade facade = new Facade();
facade.addProduct(a1);
System.out.format("Using Facade: Current price with discount: %s%n", facade.getTotalWithDiscount());
facade.addProduct(a2);
System.out.format("Using Facade: Current price with discount: %s%n", facade.getTotalWithDiscount());
facade.setDiscountCode("Discount50");
System.out.format("Using Facade: Current price with discount: %s%n", facade.getTotalWithDiscount());

//Output
//Using Facade: Current price with discount: 50.0
//Using Facade: Current price with discount: 240.0
//Using Facade: Current price with discount: 150.0

```

The Facade has a limited API that is specific to the needs of the client code. Behind the Facade lies the actual classes and interactions that do the work. **Facade** gives us benefits.

- It hides the names and APIs of the classes performing the work - it is significantly easier for the client code to deal with the Facade than with the **Basket** and **Discounter** classes.
- We could replace the **Basket** and **Discounter** classes with something else and the client code would not need to change.

> ⚠ If the underlying classes are public, it is easy for a client to ignore your Facade and work directly with the underlying classes. This is fine if the intention of the Facade is to provide a simplified way of achieving a common goal, with the intention that the client should use the underlying classes for more uncommon or complex case, but less so if the intention is to hide implementation details, so visibility is important.

> ⚠ Beware creating Facades that have more than one use case - it is tempting to add more and more functionality to the Facade API, but the objective of the Facade pattern is to simplify things for the client, and a complex Facade API that covers many use cases re-introduces complexity and is likely to be a Single Responsibility Principle (SRP) violation as well.

The general form of the Facade pattern:

```Java

class SubSystemClass1 {
    public void method1() {
    }
}

class SubSystemClass2 {
    public void method2() {
    }
}

class SubSystemClass3 {
    public void method3() {
    }
}

class Facade {

    private final SubSystemClass1 class1 = new SubSystemClass1();
    private final SubSystemClass2 class2 = new SubSystemClass2();
    private final SubSystemClass3 class3 = new SubSystemClass3();

    public void methodA() {
        class1.method1();
        class2.method2();
    }

    public void methodB() {
        class2.method2();
        class3.method3();
    }
}


//Usage
Facade facade = new Facade();
facade.methodA();
facade.methodB();
```

### Stateful and Stateless Façades
As a Façade is a normal class, it can hold *state* in private fields (instance variables) and use these fields to hold information about past calls which modifies the behavior of future calls.

In this example the StatefulFacade holds references to long-lived instances of SubSystemClasses which could themselves be stateful. In this case the client may have to retain a reference to the facade and call its methods in a specific order.

```Java
final class StatefulFacade {

    private final SubSystemClass1 class1 = new SubSystemClass1();
    private final SubSystemClass2 class2 = new SubSystemClass2();
    private final SubSystemClass3 class3 = new SubSystemClass3();

    public void methodA() {
        class1.method1();
        class2.method2();
    }

    public void methodB() {
        class2.method2();
        class3.method3();
    }
}
```

With a Stateless façade a client does not have to retain a reference to the façade, and can call any method in any order.

```Java

final class StatelessFacade {

     void methodA() {
        final SubSystemClass1 class1 = new SubSystemClass1();
        final SubSystemClass2 class2 = new SubSystemClass2();
        class1.method1();
        class2.method2();
    }

    void methodB() {
        final SubSystemClass2 class2 = new SubSystemClass2();
        final SubSystemClass3 class3 = new SubSystemClass3();
        class2.method2();
        class3.method3();
    }
}
```
> ⚠ A stateless Façade may have fields (instance variables) but those fields themselves must be immutable or stateless.

### Services
A common term in software architecture is **service**.

UML defines a **service** as a stateless, functional component (a modular, replaceable part of a system) (Object Management Group 2017 22.3).

A service might provide a service such as sending an Email or a service that implements part of a business domain such as an Ordering service, or a Product Search service.

A stateless Façade is a common way to implement a service API.

First define the service interface. Services can then have different implementations (like Strategy), for example real and fake implementations or have their lifetimes managed somewhere else in the system.

```Java
interface Service {
    void methodA();
    void methodB();
}
```

The Façade then implements the interface.

```Java

final class ServiceFacade implements Service {

     public void methodA() {
        final SubSystemClass1 class1 = new SubSystemClass1();
        final SubSystemClass2 class2 = new SubSystemClass2();
        class1.method1();
        class2.method2();
    }

    public void methodB() {
        final SubSystemClass2 class2 = new SubSystemClass2();
        final SubSystemClass3 class3 = new SubSystemClass3();
        class2.method2();
        class3.method3();
    }
}
```
The stateless Facade pattern (Service) is often used as a proxy to a networked service (i.e., a component running in a different process or computer) to the client code.

A **Microservice** architecture is an architecture where separate services implement different parts of a business domain and are run remotely from the client (commonly in Docker style containers).  **Microservices** means small, discrete, independently deployable services that when combined provide a whole business system.

> ⚠ There is little difference between how the **Service** pattern and the **Strategy** pattern are implemented and used. Services are usually much bigger in functionality (they are components) whereas Strategies are typically smaller algorithms. The concrete implementation of a Service is typically selected once when the application starts and not changed for the application lifetime, whereas the point of strategies is they encapsulate different algorithms, and the client code is constantly choosing at runtime (perhaps based on user input) which concrete strategy to use for a given situation.

## Controllers

Another special case of a stateless Façade handing user input and application flow is the **Controller** in an MVC (Model-View-Controller) pattern - a common architecture in HTTP Web Services and GUI Frameworks.

The Controller in MVC:

- Receives requests from the user interface
- Interacts with the **Model** (data and business logic) to retrieve or manipulate data.
- Selects the appropriate **View** to present the results to the user.

The Controller has a limited API that is specific to the needs of the client code. Behind the Controller are the actual classes and interactions that do the work.

## The Mediator Pattern

The job of the **Mediator** pattern is also to provide communication between classes. Unlike the **Facade** pattern, client code talks directly to individual classes (so they need to be public), but the **Mediator** manages the communication between classes "behind the scenes".

In this example, we start with the two classes that we are going to connect to the Mediator. As in the previous example, The `Basket` class holds a list of products and provides a sum of values less a discount. The `Discounter` class set the highest discount.

First we need two interfaces. Colleague and Mediator

```Java
interface Colleague {
}

interface Mediator {
    void onChanged(Colleague colleague);
}
```
Both `Basket` and `Discounter` classes implement a `Colleague` interface and have a reference to the `Mediator interface`. Both classes notify the Mediator interface when something changes using the `onChanged` method. The analogy is of colleagues in an office both reporting to a manager (the Mediator) who listens to one colleague and issues instructions to the other(s).

```Java

class Basket implements Colleague {

    private final List<Product> products = new ArrayList<>();
    private final Mediator mediator;
    double discount = 0;

    public Basket(Mediator mediator) {
        this.mediator = mediator;
    }

    public void addProduct(Product product) {
        products.add(product);
        mediator.onChanged(this);
    }

    public void removeProduct(Product product) {
        products.remove(product);
        mediator.onChanged(this);
    }

    public double getTotal() {
        return products.stream().mapToDouble(Product::getPrice).sum();
    }

    public void setDiscount(double discount) {
        this.discount = discount;
    }

    public double getTotalWithDiscount() {
        return getTotal() * (1d - discount);
    }
}

class Discounter implements Colleague {

    private static final double discount0 = 0.0d;
    private static final double discount10 = 0.1d;
    private static final double discount20 = 0.2d;
    private static final double discount30 = 0.3d;
    private static final double discount40 = 0.4d;
    private static final double discount50 = 0.5d;

    private final Mediator mediator;
    private double discount = 0d;

    public Discounter(Mediator mediator) {
        this.mediator = mediator;
    }

    public double getDiscount() {
        return discount;
    }

    public void setTotal(double total) {
        double totalDiscount = total > 100d ? discount20 : discount0;
        discount = Math.max(discount, totalDiscount);
        mediator.onChanged(this);
    }

    public void setDiscountCode(String code) {

        double codeDiscount = switch (code) {
            case "Discount10" -> discount10;
            case "Discount20" -> discount20;
            case "Discount30" -> discount30;
            case "Discount40" -> discount40;
            case "Discount50" -> discount50;
            default -> 0.0d;
        };

        discount = Math.max(discount, codeDiscount);
        mediator.onChanged(this);

    }
}
```

Finally, we create a concrete implementation of the `Mediator interface`, in this example the class is `PricingMediator`. The `PricingMediator` holds references to the concrete `Basket` and `Discounter` classes via the `registerColleagues` method, and uses reference equality (the `==` statement) to determine which object called the `onChanged` method.

```Java

class PricingMediator implements Mediator {
    private Basket basket;
    private Discounter discounter;

    public void registerColleagues(Basket basket, Discounter discounter)
    {
        this.basket = basket;
        this.discounter = discounter;
    }

    @Override
    public void onChanged(Colleague colleague) {

        if(colleague == basket)
        {
            discounter.setTotal(basket.getTotal());
        }
        if(colleague == discounter)
        {
            basket.setDiscount(discounter.getDiscount());
        }
    }
}

```

The client code uses the **Basket** and **Discounter** objects directly, but the client code is unaware of the communication between them, which happens via the `PricingMediator` class.

```Java
//Set up relationships between Mediator and Colleagues (Basket and Discounter)
PricingMediator mediator = new PricingMediator();
Basket basket = new Basket(mediator);
Discounter discounter = new Discounter(mediator);
mediator.registerColleagues(basket, discounter);

Product a1 = new Product("A1", 50.0d);
Product a2 = new Product("A2", 250.0d);

basket.addProduct(a1);
System.out.format("Using Mediator: Current price with discount: %s%n", basket.getTotalWithDiscount());
basket.addProduct(a2);
System.out.format("Using Mediator: Current price with discount: %s%n", basket.getTotalWithDiscount());
discounter.setDiscountCode("Discount50");
System.out.format("Using Mediator: Current price with discount: %s%n", basket.getTotalWithDiscount());

//Output
Using Mediator: Current price with discount: 50.0
Using Mediator: Current price with discount: 240.0
Using Mediator: Current price with discount: 150.0
```

Unlike the Facade pattern, the Mediator pattern does not hide the existence of `Basket` and `Discounter` classes from the client, but the Mediator encapsulates and hides the communication between the classes from the client code.

The colleague classes (in this case `Basket` and `Discounter`) are aware of the Mediator, unlike the Facade pattern where `Basket` and `Discounter` had no knowledge of the Facade.

The `PricingMediator` class in this example has a single `onChanged` method that will grow and become more complex if more colleagues are added, whereas a Facade may have multiple public methods each with a subset of the communication code.

### The general form of the Mediator pattern.

Start with two interfaces. In this example the colleagues send String messages, the Mediator decides who gets the message.

```Java
interface Mediator {
    void send(String s, Colleague colleague);
}

interface Colleague {
}
```
The ConcreteColleagues classes.

```Java
class ConcreteColleague1 implements Colleague {

    private final Mediator mediator;

    ConcreteColleague1(Mediator mediator) {
        this.mediator = mediator;
    }

    void notify(String s) {
        //Receive a notification from Mediator
        System.out.format("ConcreteColleague1 notified %s%n", s);
    }

    void send(String s) {
        mediator.send(s, this);
    }
}

class ConcreteColleague2 implements Colleague {

    private final Mediator mediator;

    ConcreteColleague2(Mediator mediator) {
        this.mediator = mediator;
    }

    void notify(String s) {
        System.out.format("ConcreteColleague2 notified %s%n", s);
    }

    void send(String s) {
        mediator.send(s, this);
    }
}
```
The ConcreteMediator class implements the Mediator interface, and routes messages between Colleagues

```Java
class ConcreteMediator implements Mediator {

    private ConcreteColleague1 colleague1;
    private ConcreteColleague2 colleague2;

    public void registerColleagues(ConcreteColleague1 colleague1, ConcreteColleague2 colleague2) {
        this.colleague1 = colleague1;
        this.colleague2 = colleague2;
    }

    @Override
    public void send(String s, Colleague colleague) {
        if (colleague == colleague1) {
            colleague2.notify(s);
        }
        if (colleague == colleague2) {
            colleague1.notify(s);
        }
    }
}
```



The client code.

```Java
ConcreteMediator mediator = new ConcreteMediator();
ConcreteColleague1 colleague1 = new ConcreteColleague1(mediator);
ConcreteColleague2 colleague2 = new ConcreteColleague2(mediator);
mediator.registerColleagues(colleague1,colleague2);

colleague1.send("Hello from 1");
colleague2.send("Hello from 2");

//Output
ConcreteColleague2 notified Hello from 1
ConcreteColleague1 notified Hello from 2
```
