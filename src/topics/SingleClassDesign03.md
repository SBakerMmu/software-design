#  Design of a single class - Replacing primitives with Value Objects

In all the examples we have seen we have used **primitive types** (doubles and integers for example) and Strings to hold values. It is much better to work with dedicated classes that represent the values in your software design. Although it is a bit more work to start with, every time you use an instance of your class rather than a primitive, you will see a benefit.

In an e-commerce system we can represent prices and discounts as `double` primitives. But then we rely on variable, field and parameter naming to distinguish what is the meaning of each value. 

In retail a non-discounted price is called a **Full Price**, so we can create named class that communicates the purpose of the value - the class has a name which tells us what kind of price it is.

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
```
Note that the class is **immutable** meaning that the data inside cannot be changed once created, so that they behave like primitive values (which also cannot be changed). To do this we declare all the fields as being `final` so that they can only be initialized in the constructor and never changed. 

Classes that replace the use of primitive and String values are called **Value Objects**. This isn't a term you will find in the Java specification; it just means that we have created a type that is intended to replace the use of a primitive type such as int or double, or a Jave String or date class. By using Value Objects we get the benefit of type safety

We can put all the pre-condition, post-condition and class invariant checking code in one place, guaranteeing that when we create an instance of the FullPrice class, it will be valid. As these objects are immutable, once created, they always remain valid. Clients can then just use instance without having to do further checking, because of the guarantees we have built into the class.  

Because they represent values, two instances of a Value Object are equal when the values of their instance variables are equal - in other words they have content equality. Value Object are classes that represent small things such as values or measures and provide a single place to put all their creation and usage logic.

Value Object is a **Design Pattern**. Design patterns are solutions for common problems that arise during software design and development. Design patterns are like recipes you follow to write code to solve a small, well-defined aspects of a larger software problem.

## Value Objects
- There is no special Java keyword that makes a class a Value Object.
- Value Objects are always immutable (like primitives) - their internal state cannot be changed once created.
- Value Objects usually encapsulate a small number of primitive values or other Value Objects.
- If they encapsulate reference types, then those types MUST themselves be immutable.
- Value Object implement content equality by overriding the equals() and the getHash() methods for testing the equality of contents.
- Value Object implement override the toString() method.
- We frequently create static final instances for common values. This means we don't have to create new physical instances for common values, which can be an issue in large systems. Because the Value Object is immutable, there is no problem providing a static instance.
- Being immutable, value objects are simpler to use and reason about since they can’t change state after creation. They are also inherently thread-safe, because multiple threads can use them simultaneously without risk of their state being changed.

A template for a ValueObject.

``` Java
import java.util.Objects;

public final class ValueObject {

    //Create a Constant object that represents a common value such as Zero or One, which can be used for initialization
    public final static ValueObject Zero = new ValueObject(0);
    public final static ValueObject One  = new ValueObject(1);
  
    private final int value;

    public ValueObject(int value) {
        this.value = value;
    }

    public int getValue() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        ValueObject that = (ValueObject) obj;
        return value == that.value;
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }
    
    @Override
    public String toString()
    {
    	return String.format("%d", value);
    }
}
```
### The importance of implementing `equals()` correctly.

Recall that Java has primitive and reference types. 

`==` checks value equality for primitive types, but only checks the *reference* equality of two objects (i.e. both sides of the operation are the same instance in memory). 

The default Object.equals() method also only checks the referential equality of two objects (i.e. equivalent to `==`), so we need to override this default implementation to check the contents of our class to achieve content equality. 

Writing equals() correctly requires some care. You need to determine which fields participate (usually all of them) and then write the equality test correctly. 

The signature is `public boolean equals(Object obj)` so you need to deal with `obj` being null and also `obj` being a different class (in both cases return false).

Once we have established that we are dealing with a non-null reference value of the same class, then any Java (as do similar languages) has strict rules for `equals()` with non-null object references.

- It must be **reflexive**: for any non-null reference value x, x.equals(x) should return true.
- It must be **symmetric**: for any non-null reference values x and y, x.equals(y) should return true if and only if y.equals(x) returns true.
- It must be **transitive**: for any non-null reference values x, y, and z, if x.equals(y) returns true and y.equals(z) returns true, then x.equals(z) should return true.
- It must be **consistent**: for any non-null reference values x and y, multiple invocations of x.equals(y) consistently return true or consistently return false, provided no information used in equals comparisons on the objects is modified.

> ⚠ The `equals` method of the Java String class  is case-sensitive (i.e. the character sequence must be identical),  but you might want to use `equalsIgnoreCase` version to get a case-insensitive test.

> ⚠ Defining what equals() means when comparing two collections involved depends on if the collections are ordered, in which case ordering matters, or unordered, in which case you are only interested if they have the same contents. Java Sets can help you here. 


### The importance of implementing `hashCode()` as well as `equals()`. 

> ⚠ If you implement `equals()` you must implement `hashCode() and vice-versa`.

Some algorithms and data structures use the hash code value as a representation of a contents of the object - most notably the HashMap, which uses the hash code to decide which bucket should hold a key-value pair.

As with `equals()`, there are a set of rules for implementing the `hashCode()` method.
 
- It must be **consistent** like `equals`:  `hashCode()` must consistently return the same integer, provided no information used in equals comparisons on the object is modified.
- If two objects are equal according to the `equals()` method, their `hashCode()` methods must return the same integer value.
- Hash codes are not necessarily unique, but a good hashCode() method implementation distributes values widely.

> ☑ We strongly advise you use `static int hash(Object... values)` method of `java.util.Objects` is helpful in generating suitable hash values when there are more than one field involved in the `equals`. This is surprisingly hard to do well yourself.
 
> ☑ If the Value Object is immutable (which it should be) you could calculate the hash value at construction time, and save the computation every time hashCode() is called.

## Value Objects - A worked example

Our Product class isn't very useful at present because it has nothing that identifies the product. For the product to be sold in a shop or stocked in a warehouse, are going to need a numeric identity that can be printed on a barcode and scanned in the warehouse or at a Point of Sale (POS) in a shop. 

Packaged products usually have the identity barcode on the packaging. Clothing (garments) typically have the identity barcode on a 'swing ticket' so a garment can be hung on a rail or hanger without any packaging.

There is a global standard for product ids called the GTIN or Global Trade Item Number (GS1 2024) so that products can be uniquely identified through the supply chain. The standard also specifies how a GTIN number should be represented as a barcode.

A GTIN-13 code has 13 digits 

| Company Prefix | Item Reference | Checksum Digit |
|----------------|----------------|----------------|
| 6 digits       | 6 digits       | 1 digit        |


- A 6-digit GS1 Company Prefix which is centrally allocated by the GS1 organisation to a company that wants to create a unique product id. The GS1 organisation is responsible for ensuring that every company has a unique company prefix.
- A 6-digit Item Reference which is created internally by the company - it is their responsibility to ensure that the Item Reference is unique for all the products they are responsible for.
- A 1-digit check digit which is calculated from the combination of the Company Prefix and the Item Reference and provides a check that a barcode reader can use to make sure all the digits have been read correctly by recalculating the check digit and checking it matches.

This make our product id an ideal candidate for a Value Object because it is much richer than just a string of numbers.

We start by making a class representing the 6-digit company prefix

``` Java
import java.util.Objects;

final class CompanyPrefix {
    public static final int LENGTH = 6;
    private static final int MIN = 100000; //there is a rule about GS1 Company Prefixes being > 100000
    private static final int MAX = 999999;
    private final int value;


    public CompanyPrefix(int value) throws InvalidNumberRangeException {
        if (value < MIN || value > MAX) {
            throw new InvalidNumberRangeException(value, MIN, MAX);
        }
        this.value = value;
    }

    public int get() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        CompanyPrefix that = (CompanyPrefix) obj;
        return value == that.value;
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }

    @Override
    public String toString() {
        //pad out with 0s when converting to string
        return String.format("%06d", value);
    }
}
```

and other representing the Item Reference

``` Java

public final class ItemReference {

    public static final int LENGTH = 6;
    private static final int MIN = 1;
    private static final int MAX = 999999;
    private final int value;

    public ItemReference(int value) throws InvalidNumberRangeException {
        if (value < MIN || value > MAX) {
            throw new InvalidNumberRangeException(value, MIN, MAX);
        }
        this.value = value;
    }

    public int get() {
        return value;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        ItemReference that = (ItemReference) obj;
        return value == that.value;
    }

    @Override
    public int hashCode() {
        return Objects.hash(value);
    }

    @Override
    public String toString() {
        //pad out with 0s when converting to string
        return String.format("%06d", value);
    }
}
```

Now we can create a GTIN13 value object. It can assume that the CompanyPrefix and ItemReference are valid because of the guarantees provided by those Value Objects.
Overloads of `equals` and `toString` are particularly relevant. We can also include a static parse method to convert barcode strings back to GTINs.

``` Java
import java.util.Objects;

public final class GTIN13 {
    public static final int LENGTH = CompanyPrefix.LENGTH + ItemReference.LENGTH + 1;
    private final CompanyPrefix prefix;
    private final ItemReference itemReference;
    private final int checksum;

    public GTIN13(CompanyPrefix prefix, ItemReference itemReference) throws InvalidException {
        this.prefix = prefix;
        this.itemReference = itemReference;
        this.checksum = calculateGtinCheckDigit(String.format("%s%s", this.prefix, this.itemReference));
        //post condition is that we have created a valid string representation
        requireValidGlobalTradeIdentifierString(this.toString());
    }

    public static GTIN13 parse(String s) throws InvalidException {

        s = requireValidGlobalTradeIdentifierString(s);
        CompanyPrefix prefix = new CompanyPrefix(Integer.parseInt(s.substring(0, CompanyPrefix.LENGTH)));
        ItemReference itemReference = new ItemReference(Integer.parseInt(s.substring(CompanyPrefix.LENGTH, LENGTH - 1)));
        return new GTIN13(prefix, itemReference);
    }

    public static GTIN13 tryParse(String s) throws InvalidException {

        if (isValid(s)) return parse(s);
        else return null;
    }

    static String requireValidGlobalTradeIdentifierString(String s) throws InvalidException {
        if (!isValidLength(s)) {
            throw new InvalidLengthException(s, LENGTH);
        }

        if (!isValidCharacters(s)) {
            throw new InvalidCharacterException(s);
        }

        if (!isValidCheckDigit(s)) {
            throw new InvalidCheckDigitException(s);
        }
        return s;
    }

    public static boolean isValid(String s) {
        return isValidLength(s) && isValidCharacters(s) && isValidCheckDigit(s);
    }

    static boolean isValidLength(String s) {
        return Objects.nonNull(s) && s.length() == LENGTH;
    }

    static boolean isValidCharacters(String s) {
        for (int i = 0; i < LENGTH; i++) {
            if (!Character.isDigit(s.charAt(i))) return false;
        }
        return true;
    }

    static boolean isValidCheckDigit(String s) {
        return calculateGtinCheckDigit(s.substring(0, LENGTH - 1)) == Character.getNumericValue(s.charAt(LENGTH - 1));
    }

    //Algorithm from  https://www.gs1.org/services/how-calculate-check-digit-manually
    static int calculateGtinCheckDigit(String gtinWithoutChecksum) {
        // Calculate the checksum
        int sum = 0;
        for (int i = 0; i < gtinWithoutChecksum.length(); i++) {
            int digit = Character.getNumericValue(gtinWithoutChecksum.charAt(i));
            sum += (i % 2 == 0) ? digit : digit * 3;
        }
        return (10 - (sum % 10)) % 10;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null || getClass() != obj.getClass()) {
            return false;
        }
        GTIN13 that = (GTIN13) obj;
        return prefix.equals(that.prefix) && itemReference.equals(that.itemReference) && checksum == that.checksum;
    }

    @Override
    public int hashCode() {
        return Objects.hash(prefix, itemReference, checksum);
    }

    @Override
    public String toString() {
        return String.format("%s%s%d", prefix, itemReference, checksum);
    }
}
```
The override of the equals method allows us to test equality (and note how the test is delegated to the component value objects), say from a scanned barcode string.

``` Java
CompanyPrefix prefix = new CompanyPrefix(320000);
ItemReference reference = new ItemReference(377);
GTIN13 gtin = new GTIN13(prefix,reference);
GTIN13 scannedGtin = GTIN13.parse("3200000003774");
if(scannedGtin.equals(gtin))
{
}

```

## Writing Custom Exceptions

The Java library provides standard exceptions which could be thrown when pre-conditions, post-conditions or invariants are invalid.

The above example uses a set of related custom Exception classes which are part of the representation of a GTIN13 identifier. Providing custom typed exceptions separates out the logic of creating the message, makes exceptions independently testable and provides additional context to anyone catching or reading the exception. 

``` Java
public abstract class InvalidException extends Exception {
    public InvalidException() {
    }

    public InvalidException(String message) {
        super(message);
    }
}

public class InvalidCharacterException extends InvalidException {
    public final String invalidString;

    public InvalidCharacterException(String s) {
        super(String.format("Invalid character(s) is %s", s));
        this.invalidString = s;
    }
}

public class InvalidNumberRangeException extends InvalidException {
    public final int value;
    public final int min;
    public final int max;

    public InvalidNumberRangeException(int value, int min, int max) {
        super(String.format("Expected %d to be between %d and %d", value, min, max));
        this.value = value;
        this.min = min;
        this.max = max;
    }
}

public class InvalidCheckDigitException extends InvalidException {
    public final String invalidString;

    public InvalidCheckDigitException(String s) {
        super(String.format("invalid check digit in %s", s));
        invalidString = s;
    }
}
``` 

Parsing an invalid barcode such as "3200000003779" provides a strongly typed exception as well as an informative message.

> Exception in thread "main" globaltradeitemnumber.InvalidCheckDigitException: invalid check digit in 3200000003779


## DRY, Primitive Obsessions and Value Objects

Martin and Beck (2019, p78) described the use of primitives and Strings rather than encapsulating them in meaningful classes as **Primitive Obsession** and observed that 'We find many programmers are curiously reluctant to create their own fundamental types'. The cure for Primitive Obsession is to create Value Object style classes that represent concepts in your software product.

If there are primitives in your code base chances are that some code such as checks, arithmetic, number rounding etc. will be repeated within the code base. Identifying these primitives and encapsulating them in meaningful classes means that potentially repeated code is put in one place - the encapsulated class. This is a powerful application of the **Don't repeat yourself (DRY)** principle. 

The **DRY** principal states that 'Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.' (Thomas and Hunt, 2020 Ch 8 Topic 9). When knowledge of any kind is duplicated within a software system it increases the likelihood that a change will be made in one place will but not duplicated successfully in all the others, leading to the software to diverge in its handling of that piece of knowledge. 

> ☑ Write classes conforming to the **Value Object** pattern and use as types in class fields, method parameters and method returns as replacements for primitives wherever possible. There is a small amount of up-front work to create and test the class, but the benefits are gained every time the value object is used in client code.

> ☑ When designing classes think about how you are enforcing pre-conditions, post-conditions and class invariants at the very least for the public operations.
Code that enforces pre-conditions, post-conditions and class invariants will throw exceptions. Consider creating custom exception classes that encapsulate useful information for any client handling the exception. These exception types become part of your public API. 

## A Note on Checksums in identities

A GTIN13 string is typically read using a barcode scanner but can be typed into a user interface (for example when a product won't scan at the till and the salesperson has to type the code instead - this is why the GTIN13 number is also printed below the barcode -it's called the Human Readable Interpretation in the specification). The checksum calculation provides a check that the number has been read or typed in correctly.

Another example is the long card number on a credit or debit card, which is called the PAN (Primary Account Number). Again, this is something that can be machine read (via the magnetic stripe on the back of the card) or typed in (as would be the case when typing a card number into a website or mobile app). Payment card (the generic term for credit, debit and charge cards) numbers also have a check digit, which is calculated using the [Luhn](https://en.wikipedia.org/wiki/Luhn_algorithm) algorithm.

Unlike GTINS, PAN Numbers can have different lengths but consist of a **bank identification number** (BIN), an individual customer account number and a check digit.

| BIN Number | Customer Account Number | Checksum Digit |
|------------|-------------------------|----------------|
| 6-8 digits | up to 12 digits         | 1 digit        |


**International Mobile Equipment Identity**  (IEMI) numbers (the unique identifier used with mobile phones) is another example of an identifier whose last digit is a checksum calculated using the [Luhn](https://en.wikipedia.org/wiki/Luhn_algorithm) algorithm.

> ☑ If you ever need to create an identifier that would be scanned or machine read or typed in, then you should probably consider adding a checksum digit to ensure that the user has read or typed the number correctly. As we have seen the use of Value Objects puts all the handling and validation of checksums in one place and makes it simpler for others to use the identifier without having to worry about parsing and calculating the checksum values.

## UUIDs - Universally Unique Identifiers

In computer science, a UUID is a **Universally Unique Identifier**. You may also see the term **GUID** or **Globally Unique Identifier**.

A UUID algorithm generates a 128-bit number, which is usually displayed to a human as a 36 character hex string, such as `4479e710-6ab0-4521-ac7b-ca34752774f2`. In Java the `java.util.UUID` class is a Value Object representing a UUID. The static method `public static UUID randomUUID()` generates a new random UUID.   

Unlike GTINs or PANs there is no central authority creating UUIDs - they are essentially random numbers being generated by an algorithm. Technically they are not guaranteed to be unique but the chance of a collision (two UUIDs being identical) is vanishingly small. Consequently, UUIDs are widely used to generate unique identifiers within computer programs without having to use a central source. UUIDs are applied to identify things like requests, responses, messages, log entries, versions and access tokens. There is no check digit in a UUID which makes them a poor choice for manual data entry or scanning. 

A common use case for a UUID is the primary key for a database record as any machine in a network can generate a unique UUID without the overhead of calling some central service. Whilst using UUIDs for primary keys is fine in student projects, there can be issues using UUIDs as primary keys in real-world database systems owning to their size (128bits) and randomness.