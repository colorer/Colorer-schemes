package XYZ;

class CDE {
	private DataObject processDataObject(String baseBONamespace, String boName) throws DataBindingException, BusinessObjectDefinitionNotFoundException {
	}

	private DataObject createUnstructuredContentBO(
		EmailBean bean, 
		String bidiFormat) {
			//some number literals from http://docs.oracle.com/javase/tutorial/java/nutsandbolts/datatypes.html
			int binVal = 0b11010;
			long creditCardNumber = 1234_5678_9012_3456L;
			long socialSecurityNumber = 999_99_9999L;
			float pi =  3.14_15F;
			long hexBytes = 0xFF_EC_DE_5E;
			long hexWords = 0xCAFE_BABE;
			long maxLong = 0x7fff_ffff_ffff_ffffL;
			byte nybbles = 0b0010_0101;
			long bytes = 0b11010010_01101001_10010100_10010010;
	}
}


//some annotations from https://en.wikipedia.org/wiki/Java_annotation

// Same as: @Edible(value = true)
@Edible(true)
Item item = new Carrot();
 
public @interface Edible {
	boolean value() default false;
}
 
@Author(first = "Oompah", last = "Loompah")
Book book = new Book();

public @interface Author {
	String first();
	String last();
}


@Entity                                             // Declares this an entity bean
@Table(name = "people")                             // Maps the bean to SQL table "people"
class Person implements Serializable {
	@Id                                             // Map this to the primary key column.
	@GeneratedValue(strategy = GenerationType.AUTO) // Database will generate new primary keys, not us.
	private Integer id;

	@Column(length = 32)                            // Truncate column values to 32 characters.
	private String name;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}
