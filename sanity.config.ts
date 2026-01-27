import {defineConfig} from 'sanity'
import {structureTool} from 'sanity/structure'
import {visionTool} from '@sanity/vision'
import {schemaTypes} from './schemaTypes'

export default defineConfig({
  name: 'default',
  title: 'karlduponchel',

  projectId: 'zim7ztke',
  dataset: 'portfolio',

  plugins: [structureTool(), visionTool()],

  schema: {
    types: schemaTypes,
  },
})
