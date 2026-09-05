@extends('layouts.app')

@section('content')
  {{-- greeting --}}
  <h1>{{ $title }}</h1>
  {!! $html !!}
  @if ($ok)
    <p>ok</p>
  @endif
@endsection
