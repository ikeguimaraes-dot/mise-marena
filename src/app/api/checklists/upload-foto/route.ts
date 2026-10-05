import { createServiceClient } from '@/lib/supabase/server'
import { getMiseSession } from '@/lib/session'
import { NextResponse } from 'next/server'

export async function POST(request: Request) {
  if (!await getMiseSession()) return NextResponse.json({ error: 'Não autorizado' }, { status: 401 })
  const formData = await request.formData()
  const file = formData.get('file') as File | null
  const execution_id = formData.get('execution_id') as string | null
  const item_id = formData.get('item_id') as string | null

  if (!file || !execution_id || !item_id) {
    return NextResponse.json({ error: 'file, execution_id e item_id são obrigatórios' }, { status: 400 })
  }

  const ext = file.name.split('.').pop()?.toLowerCase() ?? 'jpg'
  const timestamp = Date.now()
  const path = `${execution_id}/${item_id}/${timestamp}.${ext}`

  const supabase = createServiceClient()
  const { error: uploadError } = await supabase.storage
    .from('checklist-photos')
    .upload(path, file, { contentType: file.type, upsert: false })

  if (uploadError) {
    return NextResponse.json({ error: uploadError.message }, { status: 400 })
  }

  return NextResponse.json({ url: `/api/checklists/upload-foto?path=${encodeURIComponent(path)}` })
}

// O bucket oficial é privado; mantenha URLs estáveis sem expor seus arquivos.
export async function GET(request: Request) {
  if (!await getMiseSession()) return NextResponse.json({ error: 'Não autorizado' }, { status: 401 })
  const path = new URL(request.url).searchParams.get('path')
  if (!path || path.includes('..') || path.startsWith('/')) {
    return NextResponse.json({ error: 'Caminho inválido' }, { status: 400 })
  }
  const { data, error } = await createServiceClient().storage.from('checklist-photos').download(path)
  if (error || !data) return NextResponse.json({ error: 'Foto não encontrada' }, { status: 404 })
  return new Response(data, { headers: { 'Content-Type': data.type, 'Cache-Control': 'private, no-store' } })
}
