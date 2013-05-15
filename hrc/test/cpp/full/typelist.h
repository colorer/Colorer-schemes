#ifndef CPPD_TYPELIST
#define CPPD_TYPELIST
#include "types.h"

//
// black magic here

namespace d
{
	namespace types
	{
		#include "auto/typelist_def.h"
		
		template<class tp = nontype, TYPELIST_PVT_NAMED_LIST, int n=0>
		struct typelist : public typelist<TYPELIST_PVT_LIST, nontype, n+1>
		{
			typedef tp currtype;
			typedef typelist<TYPELIST_PVT_LIST, nontype, n+1> nexttype;
			
			enum
			{
				ind = n,
				size = nexttype::size,
				maxlen = TYPELIST_PVT_SIZE+1
			};
		};
		
		
		template<int n> 
		struct typelist<nontype, TYPELIST_PVT_NULL_LIST, n>
		{
			typedef nontype currtype;
			typedef nontype nexttype;
			
			enum
			{
				ind = n,
				size = n
			};
		};
		
		
		
		//
		// operation witch typelist
		
		namespace lst
		{
			
			//
			// get item
			// type - item type, listtype - sublist begin form type
			
			
			template<class tlist, int n>
			struct get 
			{
				static_assert(n<tlist::size);
				typedef typename get<typename tlist::nexttype,n-1>::type type;
				typedef typename get<typename tlist::nexttype,n-1>::listtype listtype;
				static_assert(n <= listtype::ind); 
			};
			
			
			template<class tlist> 
			struct get<tlist, 0>
			{
				typedef typename tlist::currtype type;
				typedef tlist listtype; 
			};
			
			
			template<int n> 
			struct get<nontype, n>
			{
				typedef nontype type;
				typedef typelist<> listtype; 
			};
			
			
			
			//
			// findfirst type
			
			template<class tlist, class tp, int off = 0>
			class find 
			{
				typedef typename get<tlist, off>::listtype subtlist;
				
			public:
				enum // static_cast need for disable gcc "enumeral mismatch" warning
				{
					res = (is_same<tp, typename subtlist::currtype>::res != 0)
						? static_cast<int>(tlist::ind)
						: static_cast<int>(find<typename subtlist::nexttype, tp>::res)
				};
				typedef typename get<tlist, res>::listtype listtype;
			};
			
			
			template<class tp, int off>
			class find<nontype, tp, off>
			{
			public:
				enum
				{
					res = -1
				};
				typedef typelist<> listtype;
			};
			
			
			
			//
			// tree class hierarchy
			
			template<class tlist, template<class, int> class base_tp>
			class classtree;
			
			
			template<class t0, TYPELIST_PVT_DECL_LIST, int n, template<class, int> class base_tp>
			class classtree<typelist<t0, TYPELIST_PVT_LIST, n>, base_tp>
			: public base_tp<t0, n>, public classtree<typename typelist<t0, TYPELIST_PVT_LIST, n>::nexttype, base_tp>
			{
				typedef typelist<t0, TYPELIST_PVT_LIST, n> sublist;
			public:
				typedef base_tp<t0, n> basetype;
				typedef typename sublist::currtype currtype;
				typedef classtree<typename sublist::nexttype, base_tp> nexttype;
				
				enum
				{
					ind = sublist::ind,
					size = sublist::size
				};
			};
			
			
			template<template<class, int> class base_tp>
			class classtree<nontype, base_tp>
			{};
		}
		
		
		
		//
		// simple tuple
		// TODO: make it via strict data operations
		
		namespace pvt
		{
			template<class tp, int n>
			struct tuple_item
			{
				tp val;
			};
		}
		
		
		template<class tp0 = nontype, TYPELIST_PVT_NAMED_LIST>
		class tuple : public lst::classtree<typelist<tp0, TYPELIST_PVT_LIST>, pvt::tuple_item>
		{
			typedef lst::classtree<typelist<tp0, TYPELIST_PVT_LIST>, pvt::tuple_item> basetree;
		public:
			template<int i>
			typename lst::get<basetree, i>::type& v()
			{
				return pvt::tuple_item<typename lst::get<basetree, i>::type, i>::val;
			}
		};
		
	}
}

#endif
