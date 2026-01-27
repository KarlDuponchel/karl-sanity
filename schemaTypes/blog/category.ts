// schemaTypes/blog/category.ts
import { defineField, defineType } from 'sanity'

export default defineType({
  name: 'category',
  title: 'Catégorie',
  type: 'document',
  fields: [
    defineField({
      name: 'title',
      title: 'Titre',
      type: 'string',
      validation: Rule => Rule.required()
    }),
    defineField({
      name: 'slug',
      title: 'Slug',
      type: 'slug',
      options: {
        source: 'title'
      }
    }),
    defineField({
      name: 'description',
      title: 'Description',
      type: 'text',
      rows: 3
    }),
    defineField({
      name: 'color',
      title: 'Couleur',
      type: 'string',
      options: {
        list: [
          { title: 'Bleu', value: 'blue' },
          { title: 'Vert', value: 'green' },
          { title: 'Rouge', value: 'red' },
          { title: 'Violet', value: 'purple' },
          { title: 'Orange', value: 'orange' }
        ]
      }
    })
  ]
})